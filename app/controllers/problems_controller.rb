class ProblemsController < ApplicationController

  load_and_authorize_resource

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
    @problem.user_id = current_user.id
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
    @problem.user_id = current_user.id;
    @problem.accessible = [:user_id] if can? :transfer, @problem # free to give others a problem to own
    @problem.attributes = params[:problem] # mass-assignment
    #if @problem.evaluator
    #  @problem.evaluator = IO.read(params[:problem][:evaluator].path)
    #end

    respond_to do |format|
      if @problem.save
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
    @problem.accessible = [:user_id] if can? :transfer, @problem   
    #if params[:problem][:evaluator] != nil
    #  params[:problem][:evaluator] = IO.read(params[:problem][:evaluator].path)
    #end

    respond_to do |format|
      if @problem.update_attributes(params[:problem])
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
