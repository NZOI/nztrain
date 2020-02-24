class ProblemsController < ApplicationController

  def permitted_params
    @_permitted_attributes ||= begin
      permitted_attributes = [:name, :statement, :memory_limit, :time_limit, :input_type, :output_type, :evaluator_id]
      permitted_attributes << :owner_id if policy(@problem || Problem).transfer?
      permitted_attributes << :input if params.require(:problem)[:input_type] == 'file'
      permitted_attributes << :output if params.require(:problem)[:output_type] == 'file'
      permitted_attributes
    end
    params.require(:problem).permit(*@_permitted_attributes)
  end

  def submit_params # attributes allowed to be included in submissions
    @_submit_attributes ||= begin
      submit_attributes = [:language_id, :source_file]
      submit_attributes << :source if policy(@problem).submit_source?
      submit_attributes
    end
    p = params.require(:submission).permit(*@_submit_attributes).merge(:user_id => current_user.id, :problem_id => params[:id])
    p
  end

  def visible_attributes
    @_visible_attributes ||= begin
      visible_attributes = [:linked_name, :input, :output, :memory_limit, :time_limit, :linked_owner, :progress_bar]
      visible_attributes << :edit_link if policy(@problem).update?
      visible_attributes << :destroy_link if policy(@problem).destroy?
      visible_attributes << :test_status if policy(@problem).inspect?
      visible_attributes
    end
  end

  # GET /problems
  # GET /problems.xml
  def index
    raise Pundit::NotAuthorizedError if current_user.nil?
    case params[:filter].to_s
    when 'my'
      @problem = Problem.new(:owner_id => current_user.id)
      @problems = Problem.where(:owner_id => current_user.id).score_by_user(current_user.id).select('*')
    else
      @problem = Problem.new
      @problems = Problem.score_by_user(current_user.id).select('*')
    end
    @problems = @problems.order(id: :desc)
    authorize @problem, :update?

    @problems_presenter = ProblemPresenter::Collection.new(@problems).permit!(*visible_attributes)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /problems/1
  # GET /problems/1.xml
  def show
    @problem = Problem.find(params[:id])
    authorize @problem, :show?

    #TODO: restrict to problems that current user owns/manages
    @problem_sets = ProblemSet.all.select { |set| policy(set).use? } # TODO: fix to be more efficient
    @submissions = @problem.submission_history(current_user)

    @all_subs = {};
    @sub_count = {};
    @problem.submissions.each do |sub|
    	  @all_subs[sub.user] = [(@all_subs[sub.user] or sub), sub].max_by {|m| m.score or 0 }
          @sub_count[sub.user] = (@sub_count[sub.user] or 0) + 1
    end
    @all_subs = @all_subs.map {|s| s[1]}

    respond_to do |format|
      format.html { render :layout => "problem" }
    end

    if user_signed_in?
      UserProblemRelation.where(:user_id => current_user.id, :problem_id => params[:id]).first_or_create!.view! unless in_su?
    end
  end

  def submit
    @problem = Problem.find(params[:id])
    authorize @problem, :submit?
    if request.post? # post request
      @problem = Problem.find(params[:id])
      @submission = Submission.new(submit_params) # create submission
      respond_to do |format|
        if @submission.save
          @submission.judge
          format.html { redirect_to(@submission, :notice => 'Submission was successfully created.') }
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
        else
          format.html { render :action => "submit", :layout => "problem", :alert => 'Submission failed.' }
          format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
        end
      end
    else # get request
      @problem = Problem.find(params[:id])
      @submission = Submission.new
      respond_to do |format|
        format.html { render :layout => "problem" }
      end
    end
  end

  def submissions
    @problem = Problem.find(params[:id])
    authorize @problem, :view_submissions?
    @problem = Problem.find(params[:id])
    if current_user.openbook?
      @submissions = @problem.submission_history(current_user)
    else
      start_time = current_user.contest_relations.joins(:contest => {:problem_set => :problems}).where{(started_at <= DateTime.now) & (finish_at > DateTime.now) & (contest.problem_set.problems.id == my{params[:id]})}.minimum(:started_at)
      @submissions = @problem.submission_history(current_user,start_time)
    end
    
    respond_to do |format|
      format.html { render :layout => "problem" }
    end
  end

  def test_cases
    @problem = Problem.find(params[:id])
    authorize @problem, :inspect?
    respond_to do |format|
      format.html { render :layout => "problem" }
    end
  end

  def import
    @problem = Problem.find(params[:id])
    authorize @problem, :update?
    options = {:merge => params[:upload] == 'merge'}
    if !params[:import_file].nil?
      importdata = params[:import_file].path
      options[:extension] = File.extname(params[:import_file].original_filename)
      options.delete(:extension) if options[:extension].empty?
    elsif params[:import_yaml] && params[:import_yaml] != ""
      importdata = params[:import_yaml]
      options[:inline] = true
    else
      redirect_to(problem_test_cases_path(@problem), :alert => 'No zip file uploaded') and return
    end
    redirect_to(problem_test_cases_path(@problem), :alert => 'Invalid importer specified') and return if !Problems::Importers.has_key?(params[:importer])
    message = {notice: ""}
    begin
      original_total_time = @problem.test_cases.count * (@problem.time_limit || 0)
      if Problems::Importers[params[:importer]].import(@problem, importdata, options)
        message[:notice] = "Successfully uploaded. New counts for the problem are: # Test Sets: #{ @problem.test_sets.count }, # Test Cases: #{ @problem.test_cases.count }. "
      else
        message[:alert] = 'No test cases or test sets detected. '
      end
    rescue Problems::Importers[params[:importer]]::ImportError => e
      message[:alert] = e.message
    ensure
      available_time = [original_total_time, policy(@problem).maximum_total_time_limit].max
      if available_time < (@problem.time_limit || 0)*@problem.test_cases.count
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
    name = @problem.name.gsub(/[\W]/,"")
    name = "testcases" if name.empty?
    filename = name + ".zip"

    dir = Dir.mktmpdir("zip-testcases-#{@problem.id}-#{current_user.id}-#{Time.now}")
    zipfile = Problems::TestCaseExporter.export(@problem, File.expand_path(filename, dir))

    send_file zipfile, :type => 'application/zip', :disposition => 'attachment', :filename => filename
  end

  def testing
    @problem = Problem.find(params[:id])
    authorize @problem, :inspect?
    @submissions = @problem.test_submissions
    respond_to do |format|
      format.html { render :layout => "problem" }
    end
  end

  # GET /problems/new
  def new
    @problem = Problem.new(:owner => current_user)
    authorize @problem, :new?
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /problems/1/edit
  def edit
    @problem = Problem.find(params[:id])
    authorize @problem, :edit?
  end

  # POST /problems
  def create
    @problem = Problem.new(permitted_params)
    @problem.owner ||= current_user
    authorize @problem, :create?

    respond_to do |format|
      if validate(@problem) && @problem.save
        format.html { redirect_to(@problem, :notice => 'Problem was successfully created.') }
        format.xml  { render :xml => @problem, :status => :created, :location => @problem }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @problem.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /problems/1
  # PUT /problems/1.xml
  def update
    @problem = Problem.find(params[:id])
    authorize @problem, :update?
    
    @problem.assign_attributes(permitted_params)
    respond_to do |format|
      if validate(@problem) && @problem.save
        format.html { redirect_to(@problem, :notice => 'Problem was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @problem.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /problems/1
  # DELETE /problems/1.xml
  def destroy
    @problem = Problem.find(params[:id])
    authorize @problem, :destroy?
    @problem.destroy

    respond_to do |format|
      format.html { redirect_to(problems_url) }
      format.xml  { head :ok }
    end
  end

  # Remove the current problem from the selected problem set and refresh the page
  def remove_from_problem_set
    problem_set = ProblemSet.find(params[:problem_set_id])
    @problem = Problem.find(params[:id])
    problem_set.problems.delete(@problem)
    redirect_to(@problem, :notice => "Removed from the '#{problem_set.name}' problem set.")
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
