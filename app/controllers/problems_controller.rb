class ProblemsController < ApplicationController
  def permitted_params
    permitted_attributes = [:name, :statement, :memory_limit, :time_limit, :input_type, :output_type, :evaluator_id]
    permitted_attributes << :owner_id if policy(@problem || Problem).transfer?
    permitted_attributes << :input if params.require(:problem)[:input_type] == "file"
    permitted_attributes << :output if params.require(:problem)[:output_type] == "file"
    params.require(:problem).permit(*permitted_attributes)
  end

  # attributes allowed to be included in submissions
  def submit_params
    submit_attributes = [:language_id, :source_file]
    submit_attributes << :source if policy(@problem).submit_source?
    params.require(:submission).permit(*submit_attributes).merge(user_id: current_user.id, problem_id: params[:id])
  end

  def index
    raise Pundit::NotAuthorizedError if current_user.nil?
    case params[:filter].to_s
    when "my"
      @problem = Problem.new(owner_id: current_user.id)
      @problems = Problem.where(owner_id: current_user.id).score_by_user(current_user.id).select("*")
    else
      @problem = Problem.new
      @problems = Problem.score_by_user(current_user.id).select("*")
    end
    @problems = @problems.order(id: :desc)
    authorize @problem, :update?
  end

  def show
    @problem = Problem.find(params[:id])
    authorize @problem, :show?

    # TODO: restrict to problems that current user owns/manages
    @problem_sets = ProblemSet.all.select { |set| policy(set).use? } # TODO: fix to be more efficient
    @submissions = @problem.submission_history(current_user)

    @all_subs = {}
    @sub_count = {}
    @problem.submissions.each do |sub|
      @all_subs[sub.user] = [(@all_subs[sub.user] or sub), sub].max_by { |m| m.score or 0 }
      @sub_count[sub.user] = (@sub_count[sub.user] or 0) + 1
    end
    @all_subs = @all_subs.map { |s| s[1] }

    if user_signed_in?
      UserProblemRelation.where(user_id: current_user.id, problem_id: params[:id]).first_or_create!.view! unless in_su?
    end

    render layout: "problem"
  end

  def submit
    @problem = Problem.find(params[:id])
    authorize @problem, :submit?
    if request.post? # post request
      @submission = Submission.new(submit_params) # create submission
      source_is_valid = @submission.source.nil? || @submission.source.valid_encoding? && !@submission.source.include?("\0")

      if !source_is_valid
        @submission.errors.add :source_file, "has an invalid text encoding. This was likely caused by submitting a compiled file (.exe, .out, .class, ...) instead of a source code file (.cpp, .c, .java, ...)."
        @submission.source = nil; # Prevent submission form from trying to render the source (and erroring)
      end

      if source_is_valid && @submission.save
        @submission.judge
        redirect_to(@submission, notice: "Submission was successfully created.")
      else
        render action: "submit", layout: "problem", alert: "Submission failed."
      end
    else # get request
      @submission = Submission.new
      render layout: "problem"
    end
  end

  def submissions
    @problem = Problem.find(params[:id])
    authorize @problem, :view_submissions?
    if current_user.openbook?
      @submissions = @problem.submission_history(current_user)
    else
      start_time = current_user
        .contest_relations
        .joins(contest: {problem_set: :problems})
        .where("started_at <= :now AND finish_at > :now", now: DateTime.now)
        .where(problems: {id: params[:id]})
        .minimum(:started_at)

      @submissions = @problem.submission_history(current_user, start_time)
    end

    render layout: "problem"
  end

  def test_cases
    @problem = Problem.find(params[:id])
    authorize @problem, :inspect?

    render layout: "problem"
  end

  def import
    @problem = Problem.find(params[:id])
    authorize @problem, :update?
    options = {merge: params[:upload] == "merge"}
    if !params[:import_file].nil?
      importdata = params[:import_file].path
      options[:extension] = File.extname(params[:import_file].original_filename)
      options.delete(:extension) if options[:extension].empty?
    elsif params[:import_yaml] && params[:import_yaml] != ""
      importdata = params[:import_yaml]
      options[:inline] = true
    else
      redirect_to(problem_test_cases_path(@problem), alert: "No zip file uploaded") and return
    end
    redirect_to(problem_test_cases_path(@problem), alert: "Invalid importer specified") and return unless Problems::Importers.has_key?(params[:importer])
    message = {notice: ""}
    begin
      original_total_time = @problem.test_cases.count * (@problem.time_limit || 0)
      if Problems::Importers[params[:importer]].import(@problem, importdata, options)
        message[:notice] = "Successfully uploaded. New counts for the problem are: # Test Sets: #{@problem.test_sets.count}, # Test Cases: #{@problem.test_cases.count}. "
      else
        message[:alert] = "No test cases or test sets detected. "
      end
    rescue Problems::Importers[params[:importer]]::ImportError => e
      message[:alert] = e.message
    ensure
      available_time = [original_total_time, policy(@problem).maximum_total_time_limit].max
      if available_time < (@problem.time_limit || 0) * @problem.test_cases.count
        @problem.time_limit = available_time / @problem.test_cases.count
        @problem.save
        message[:alert] = "#{message[:alert]}Time limit reduced to #{@problem.time_limit} to meet total judging time limits."
      end
    end

    redirect_to(problem_test_cases_path(@problem), message)
  end

  def export
    @problem = Problem.find(params[:id])
    authorize @problem, :inspect?
    name = @problem.name.gsub(/\W/, "")
    name = "testcases" if name.empty?
    filename = name + ".zip"

    dir = Dir.mktmpdir("zip-testcases-#{@problem.id}-#{current_user.id}-#{Time.now}")
    zipfile = Problems::TestCaseExporter.export(@problem, File.expand_path(filename, dir))

    send_file zipfile, type: "application/zip", disposition: "attachment", filename: filename
  end

  def testing
    @problem = Problem.find(params[:id])
    authorize @problem, :inspect?
    @submissions = @problem.test_submissions

    render layout: "problem"
  end

  def new
    @problem = Problem.new(owner: current_user)
    authorize @problem, :new?
  end

  def edit
    @problem = Problem.find(params[:id])
    authorize @problem, :edit?
  end

  def create
    @problem = Problem.new(permitted_params)
    @problem.owner ||= current_user
    authorize @problem, :create?

    if validate(@problem) && @problem.save
      redirect_to(@problem, notice: "Problem was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @problem = Problem.find(params[:id])
    authorize @problem, :update?

    @problem.assign_attributes(permitted_params)

    if validate(@problem) && @problem.save
      redirect_to(@problem, notice: "Problem was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @problem = Problem.find(params[:id])
    authorize @problem, :destroy?
    @problem.destroy!

    redirect_to(problems_url)
  end

  # Remove the current problem from the selected problem set and refresh the page
  def remove_from_problem_set
    problem_set = ProblemSet.find(params[:problem_set_id])
    @problem = Problem.find(params[:id])
    problem_set.problems.delete(@problem)
    redirect_to(@problem, notice: "Removed from the '#{problem_set.name}' problem set.")
  end

  private

  def validate(problem)
    if policy(problem).maximum_memory_limit < (params.require(:problem)[:memory_limit].to_f || 0)
      problem.errors.add :memory_limit, "The maximum allowed memory limit is #{policy(problem).maximum_memory_limit} MB"
    end
    if policy(problem).maximum_time_limit < (params.require(:problem)[:time_limit].to_f || 0)
      problem.errors.add :time_limit, "The maximum allowed judging time is #{policy(problem).maximum_total_time_limit} seconds for a maximum time limit of #{policy(problem).maximum_time_limit} seconds per test case"
    end
    problem.errors.empty?
  end
end
