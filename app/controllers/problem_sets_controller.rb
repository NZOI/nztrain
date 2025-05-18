class ProblemSetsController < ApplicationController
  def permitted_params
    permitted_attributes = [:name, problem_associations_attributes: [:id, :problem_set_order_position, :weighting]]
    permitted_attributes << :owner_id if policy(@problem_set || ProblemSet).transfer?
    params.require(:problem_set).permit(*permitted_attributes)
  end

  # unused
  def add_problem
    @problem_set = ProblemSet.find(params[:problem][:problem_set_ids])
    authorize @problem_set, :update?
    problem = Problem.find(params[:id]) # note switched params - TODO: fix form
    authorize problem, :use?
    if @problem_set.problems.exists?(problem.id)
      redirect_to(problem, alert: "This problem set already contains this problem")
      return
    end
    @problem_set.problems.push(problem)
    redirect_to(problem, notice: "Problem added.")
  end

  def remove_problem
    @problem_set = ProblemSet.find(params[:id])
    problem = Problem.find(params[:problem_id])
    @problem_set.problems.delete(problem)
    redirect_to(@problem_set, notice: "Problem removed.")
  end

  def index
    case params[:filter].to_s
    when "my"
      authorize ProblemSet.new(owner_id: current_user.id), :manage?
      @problem_sets = ProblemSet.where(owner_id: current_user.id)
    else
      authorize ProblemSet.new, :manage?
      @problem_sets = ProblemSet.all
    end
    @problem_sets = @problem_sets.order(name: :asc).page(params[:page]).per_page(25)
  end

  def show
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :show?
    if user_signed_in?
      @groups = if policy(Group.new).update?
        Group.all
      else
        Group.where(owner_id: current_user.id)
      end
    end
  end

  def new
    @problem_set = ProblemSet.new(owner: current_user)
    authorize @problem_set, :new?
  end

  def edit
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :edit?
  end

  def create
    @problem_set = ProblemSet.new(permitted_params)
    @problem_set.owner ||= current_user
    authorize @problem_set, :create?

    if @problem_set.save
      redirect_to(@problem_set, notice: "Problem set was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :update?

    if @problem_set.update_attributes(permitted_params)
      redirect_to(@problem_set, notice: "Problem set was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :destroy?
    @problem_set.destroy

    redirect_to(problem_sets_url)
  end
end
