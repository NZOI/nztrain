class SubmissionsController < ApplicationController

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:problem_id, :source, :language_id]
      permitted_attributes << :classification if policy(@submission).allowed_classifications.include?(params[:submission][:classification].to_i)
      params.require(:submission).permit(*permitted_attributes)
    end
  end

  has_scope :by_user
  has_scope :by_problem

  # GET /submissions
  # GET /submissions.xml
  def index
    params[:by_user] = current_user.id if params[:filter] == 'my'
    authorize Submission.new, :show? if params[:by_user].nil?
    if current_user.openbook? || policy(Problem.new).show?
      authorize Problem.find(params[:by_problem]), :show? unless params[:by_problem].nil?
      @submissions = apply_scopes(Submission)
    else # only allowed to see contest submissions
      @submissions = policy_scope(Submission)
    end
    @submissions = @submissions.order(created_at: :desc).page(params[:page]).per_page(20)
    # TODO: fix submission permissions

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @submissions }
    end
  end

  # GET /submissions/1
  # GET /submissions/1.xml
  def show
    @submission = Submission.find(params[:id])
    authorize @submission, :show?
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  # GET /submissions/new
  # GET /submissions/new.xml
  def new
    @submission = Submission.new
    authorize @submission, :new?
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
    authorize @submission, :edit?
    @problem = @submission.problem
  end

  def rejudge
    @submission = Submission.find(params[:id])
    authorize @submission, :rejudge?
    if @submission.rejudge
      redirect_to @submission, :notice => "Rejudge request queued."
    else
      redirect_to @submission, :alert => "Rejudge request failed."
    end
  end

  # POST /submissions
  # POST /submissions.xml
  def create
    # don't let users submit to problems they don't have access to (which they could do by id speculatively to try get access to problem name, # of test cases etc.) (ie. they should have read access)
    authorize Problem.find(params[:submission][:problem_id]), :submit?
    params[:submission][:source] = IO.read(params[:submission][:source].path)
    @submission = Submission.new(permitted_params.merge(:score => nil, :user_id => current_user.id))
    authorize @submission, :create?
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
    authorize @submission, :update?
    params[:submission][:source] = IO.read(params[:submission][:source].path) if params[:submission][:source]

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
    @submission = Submission.find(params[:id])
    authorize @submission, :destroy?
    @submission.destroy

    respond_to do |format|
      format.html { redirect_to(submissions_url) }
      format.xml  { head :ok }
    end
  end
end
