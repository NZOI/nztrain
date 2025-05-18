class SubmissionsController < ApplicationController
  def permitted_params
    permitted_attributes = [:problem_id, :source, :language_id]
    permitted_attributes << :classification if policy(@submission).allowed_classifications.include?(params[:submission][:classification].to_i)
    params.require(:submission).permit(*permitted_attributes)
  end

  has_scope :by_user
  has_scope :by_problem

  def index
    params[:by_user] = current_user.id.to_s if params[:filter] == "my"
    if !params[:by_user].nil? && params[:by_user].to_i != current_user.id
      authorize User.find(params[:by_user]), :inspect?
    end
    authorize Submission.new, :show? if params[:by_user].nil?
    if current_user.openbook? || policy(Problem.new).show?
      authorize Problem.find(params[:by_problem]), :show? unless params[:by_problem].nil?
      @submissions = apply_scopes(Submission)
    else # only allowed to see contest submissions
      @submissions = policy_scope(Submission)
    end
    @submissions = @submissions.order(created_at: :desc).page(params[:page]).per_page(20)
    # TODO: fix submission permissions
  end

  def show
    @submission = Submission.find(params[:id])
    authorize @submission, :show?
  end

  def new
    @submission = Submission.new
    authorize @submission, :new?
    @problem = params[:problem]
    logger.debug "going to submit, problem is #{@problem} and params are:"
    logger.debug params
  end

  def edit
    @submission = Submission.find(params[:id])
    authorize @submission, :edit?
    @problem = @submission.problem
  end

  def rejudge
    @submission = Submission.find(params[:id])
    authorize @submission, :rejudge?
    if @submission.rejudge
      redirect_to @submission, notice: "Rejudge request queued."
    else
      redirect_to @submission, alert: "Rejudge request failed."
    end
  end

  def create
    # don't let users submit to problems they don't have access to (which they could do by id speculatively to try get access to problem name, # of test cases etc.) (ie. they should have read access)
    authorize Problem.find(params[:submission][:problem_id]), :submit?
    params[:submission][:source] = IO.read(params[:submission][:source].path)
    @submission = Submission.new(permitted_params.merge(score: nil, user_id: current_user.id))

    authorize @submission, :create?

    if @submission.save
      @submission.judge
      redirect_to(@submission, notice: "Submission was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @submission = Submission.find(params[:id])
    authorize @submission, :update?

    params[:submission][:source] = IO.read(params[:submission][:source].path) if params[:submission][:source]

    if @submission.update_attributes(permitted_params)
      redirect_to(@submission, notice: "Submission was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @submission = Submission.find(params[:id])
    authorize @submission, :destroy?

    @submission.destroy!

    redirect_to(submissions_url)
  end
end
