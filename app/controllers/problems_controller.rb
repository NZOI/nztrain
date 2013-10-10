class ProblemsController < ApplicationController
  filter_resource_access :additional_member => {:submit => :submit, :submissions => :submit}

  def permitted_params
    @_permitted_attributes ||= begin
      permitted_attributes = [:title, :statement, :input_type, :output_type, :memory_limit, :time_limit, :evaluator_id]
      permitted_attributes << :owner_id if permitted_to? :transfer, @problem
      permitted_attributes << :input if params.require(:problem)[:input_type] == 'file'
      permitted_attributes << :output if params.require(:problem)[:output_type] == 'file'
      permitted_attributes
    end
    params.require(:problem).permit(*@_permitted_attributes)
  end

  def submit_params # attributes allowed to be included in submissions
    @_submit_attributes ||= begin
      submit_attributes = [:language, :source_file]
      submit_attributes << :source if permitted_to? :submit_source, @problem
      submit_attributes
    end
    params.require(:submission).permit(*@_submit_attributes).merge(:user_id => current_user.id, :problem_id => params[:id])
  end

  def new_problem_from_params
    @problem = Problem.new(:owner => current_user)
  end

  def visible_attributes
    @_visible_attributes ||= begin
      visible_attributes = [:linked_title, :input, :output, :memory_limit, :time_limit, :linked_owner, :progress_bar]
      visible_attributes << :edit_link if permitted_to? :update, @problem
      visible_attributes << :destroy_link if permitted_to? :destroy, @problem
      visible_attributes
    end
  end

  # GET /problems
  # GET /problems.xml
  def index
    case params[:filter].to_s
    when 'my'
      @problem = Problem.new(:owner_id => current_user.id)
      @problems = Problem.where(:owner_id => current_user.id).score_by_user(current_user.id).select('*')
    else
      @problem = Problem.new
      @problems = Problem.score_by_user(current_user.id).select('*')
    end
    permitted_to! :manage, @problem

    @problems_presenter = ProblemPresenter.wrap_each(@problems).permit(*visible_attributes)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @problems }
    end
  end

  # GET /problems/1
  # GET /problems/1.xml
  def show
    #TODO: restrict to problems that current user owns/manages
    #@problem_sets = ProblemSet.accessible_by(current_ability,:update) # can only add problem to problem sets user can update to
    @problem_sets = ProblemSet.with_permissions_to(:update) if permitted_to? :update, :problem_sets # can only add problem to problem sets user can update to
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
      format.xml  { render :xml => @problem }
    end
  end

  def submit
    if request.post? # post request
      @problem = Problem.find(params[:id])
      @submission = Submission.new(submit_params) # create submission
      respond_to do |format|
        if @submission.save
          Rails.env == 'test' ? @submission.judge : spawn { @submission.judge }
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
        format.xml  { render :xml => @problem }
      end
    end
  end

  def submissions
    @problem = Problem.find(params[:id])
    if current_user.openbook?
      @submissions = @problem.submission_history(current_user)
    else
      start_time = current_user.contest_relations.joins(:contest => {:problem_set => :problems}).where{(started_at <= DateTime.now) & (finish_at > DateTime.now) & (contest.problem_set.problems.id == my{params[:id]})}.minimum(:started_at)
      @submissions = @problem.submission_history(current_user,start_time)
    end
    
    respond_to do |format|
      format.html { render :layout => "problem" }
      format.xml  { render :xml => @problem }
    end
  end

  # GET /problems/new
  # GET /problems/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @problem }
    end
  end

  # GET /problems/1/edit
  def edit
  end

  # POST /problems
  # POST /problems.xml
  def create
    respond_to do |format|
      if @problem.update_attributes(permitted_params)
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
    respond_to do |format|
      if @problem.update_attributes(permitted_params)
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
    @problem.destroy

    respond_to do |format|
      format.html { redirect_to(problems_url) }
      format.xml  { head :ok }
    end
  end
end
