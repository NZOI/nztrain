class RolesController < ApplicationController
  def permitted_params
    permitted_attributes = [:name]
    params.require(:role).permit(*permitted_attributes)
  end

  def index
    authorize Role.new, :index?
    @roles = policy_scope(Role)
  end

  def show
    @role = Role.find(params[:id])
    authorize @role, :show?
  end

  def new
    @role = Role.new
    authorize @role, :new?
  end

  def edit
    @role = Role.find(params[:id])
    authorize @role, :edit?
  end

  def create
    @role = Role.new(permitted_params)
    authorize @role, :create?

    if @role.save
      redirect_to(@role, notice: "Role was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @role = Role.find(params[:id])
    authorize @role, :update?

    if @role.update_attributes(permitted_params)
      redirect_to(@role, notice: "Role was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @role = Role.find(params[:id])
    authorize @role, :destroy?

    @role.destroy!

    redirect_to(roles_url)
  end
end
