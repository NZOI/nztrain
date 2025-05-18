class EvaluatorsController < ApplicationController
  def permitted_params
    permitted_attributes = [:name, :description, :source, :language_id]
    permitted_attributes << :owner_id if policy(@evaluator || Evaluator).transfer?
    params.require(:evaluator).permit(*permitted_attributes)
  end

  def index
    authorize Evaluator, :index?
    @evaluators = Evaluator.all.order(id: :asc)
  end

  def show
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :show?
  end

  def new
    @evaluator = Evaluator.new(owner_id: current_user.id)
    authorize @evaluator, :new?
  end

  def edit
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :edit?
  end

  def create
    @evaluator = Evaluator.new(permitted_params)
    @evaluator.owner_id ||= current_user.id
    authorize @evaluator, :create?

    if @evaluator.save
      redirect_to(@evaluator, notice: "Evaluator was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :update?

    if @evaluator.update_attributes(permitted_params)
      redirect_to(@evaluator, notice: "Evaluator was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :destroy?
    @evaluator.destroy

    redirect_to(evaluators_url)
  end
end
