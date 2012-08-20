class ProblemsController < ApplicationController
  load_and_authorize_resource :except => [:create]

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:title, :statement, :input, :output, :memory_limit, :time_limit, :evaluator_id]
      permitted_attributes << :owner_id if can? :transfer, @problem
      params.require(:problem).permit(*permitted_attributes)
    end
  end

  # GET /problems
  # GET /problems.xml
  def index
    @problems = @problems.distinct.score_by_user(current_user.id)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @problems }
    end
  end

  # GET /problems/1
  # GET /problems/1.xml
  def show
    @submission = Submission.new # for submitting problem
    #TODO: restrict to problems that current user owns/manages
    @problem_sets = ProblemSet.accessible_by(current_ability,:update) # can only add problem to problem sets user can update to
    @submissions = @problem.submission_history(current_user)

    @all_subs = {};
    @sub_count = {};
    @problem.submissions.each do |sub|
    	@all_subs[sub.user] = [(@all_subs[sub.user] or sub), sub].max_by {|m| m.score}
        @sub_count[sub.user] = (@sub_count[sub.user] or 0) + 1
    end
    @all_subs = @all_subs.map {|s| s[1]}

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @problem }
    end
  end

  # GET /problems/new
  # GET /problems/new.xml
  def new
    @problem.owner_id = current_user.id
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
    @problem = Problem.new(:owner_id => current_user.id)
    authorize! :create, @problem

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
