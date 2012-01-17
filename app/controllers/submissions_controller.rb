class SubmissionsController < ApplicationController
  before_filter :check_signed_in
  before_filter :check_access, :only => [:show]
  before_filter :check_admin, :only => [:edit, :update, :destroy]
  # GET /submissions
  # GET /submissions.xml

  def check_access
    if current_user.is_admin
      return true
    end

    @submission = Submission.find(params[:id])
    if @submission.user_id != current_user.id
	    redirect("This is not your submission!")
    end
  end

  def index
    if !current_user.is_admin
      params[:user_id]=current_user.id # non-admins can only browse their own submissions
    end
    @submissions = Submission.submission_history(params[:user_id], params[:problem_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @submissions }
    end
  end

  # GET /submissions/1
  # GET /submissions/1.xml
  def show
    @submission = Submission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  # GET /submissions/new
  # GET /submissions/new.xml
  def new
    @submission = Submission.new
    @problem = params[:problem]
    logger.debug "going to submit, problem is #{@problem} and params are:"
    logger.debug params

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  # GET /submissions/1/edit
  def edit
    @submission = Submission.find(params[:id])
    @problem = @submission.problem
  end

  # POST /submissions
  # POST /submissions.xml
  def create
    logger.debug "creating new submission , problem is #{@defaultProblem} and params are:"
    logger.debug params
    @submission = Submission.new(params[:submission])
    @submission.source = IO.read(params[:submission][:source].path)
    @submission.user = current_user
    @submission.score = 0

    respond_to do |format|
      if @submission.save
        spawn do 
          @submission.judge
        end
        format.html { redirect_to(@submission, :notice => 'Submission was successfully created.') }
        format.xml  { render :xml => @submission, :status => :created, :location => @submission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /submissions/1
  # PUT /submissions/1.xml
  def update
    @submission = Submission.find(params[:id])
    @submission.source = IO.read(params[:submission][:source].path)

    respond_to do |format|
      if @submission.update_attributes(params[:submission])
        format.html { redirect_to(@submission, :notice => 'Submission was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.xml
  def destroy
    @submission = Submission.find(params[:id])
    @submission.destroy

    respond_to do |format|
      format.html { redirect_to(submissions_url) }
      format.xml  { head :ok }
    end
  end
end
