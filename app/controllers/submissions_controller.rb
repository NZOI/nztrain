class SubmissionsController < ApplicationController
  before_filter :check_signed_in
  load_and_authorize_resource

  has_scope :by_user
  has_scope :by_problem

  # GET /submissions
  # GET /submissions.xml
  def index
    @submissions = apply_scopes(Submission).accessible_by(current_ability).distinct.paginate(:order => "created_at DESC", :page => params[:page], :per_page => 50)

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb (for AJAX pagination)
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

  def rejudge
    @submission = Submission.find(params[:id])
    @submission.judge_output = nil
    if @submission.save
      logger.debug "rejudging submission id #{@submission.id}"
      spawn do
        @submission.judge
      end
      redirect_to @submission, :notice => "Rejudge request queued."
    end
  end

  # POST /submissions
  # POST /submissions.xml
  def create
    # don't let users submit to problems they don't have access to (which they could do by id speculatively to try get access to problem title, # of test cases etc.) (ie. they should have read access)
    authorize! :read, Problem.find(params[:submission][:problem_id])
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
