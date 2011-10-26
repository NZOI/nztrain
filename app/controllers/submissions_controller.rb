class SubmissionsController < ApplicationController
  before_filter :check_signed_in
  before_filter :check_access, :only => [:show]
  before_filter :check_admin, :only => [:edit, :index, :update, :destroy]
  # GET /submissions
  # GET /submissions.xml

  def check_access
    if current_user.is_admin
      return true
    end

    @submission = Submission.find(params[:id])
    return @submission.user_id == current_user
  end

  def index
    @submissions = Submission.all

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
        @submission.judge
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
