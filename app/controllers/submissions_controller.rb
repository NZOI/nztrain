class SubmissionsController < ApplicationController
  load_and_authorize_resource :except => [:create]

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:problem_id, :source, :language]
      params.require(:submission).permit(*permitted_attributes)
    end
  end

  has_scope :by_user
  has_scope :by_problem

  # GET /submissions
  # GET /submissions.xml
  def index
    @submissions = apply_scopes(@submissions).distinct.paginate(:order => "created_at DESC", :page => params[:page], :per_page => 50)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @submissions }
      ajax_respond format, :section_id => "page"
    end
  end

  # GET /submissions/1
  # GET /submissions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  # GET /submissions/new
  # GET /submissions/new.xml
  def new
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
    @problem = @submission.problem
  end

  def rejudge
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
    logger.debug "creating new submission , problem is #{params[:submission][:problem_id]} and params are:"
    logger.debug params
    params[:submission][:source] = IO.read(params[:submission][:source].path)
    @submission = Submission.new(permitted_params.merge(:score => nil, :user_id => current_user.id))

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
    params[:submission][:source] = IO.read(params[:submission][:source].path)

    respond_to do |format|
      if @submission.update_attributes(permitted_params)
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
    @submission.destroy

    respond_to do |format|
      format.html { redirect_to(submissions_url) }
      format.xml  { head :ok }
    end
  end
end
