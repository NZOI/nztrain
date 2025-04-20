class RolesController < ApplicationController
  def permitted_params
    permitted_attributes = [:name]
    params.require(:role).permit(*permitted_attributes)
  end

  # GET /roles
  # GET /roles.xml
  def index
    authorize Role.new, :index?
    @roles = policy_scope(Role)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])
    authorize @role, :show?
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render xml: @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new
    authorize @role, :new?
    respond_to do |format|
      format.html # new.html.erb
      format.xml { render xml: @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
    authorize @role, :edit?
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(permitted_params)
    authorize @role, :create?
    respond_to do |format|
      if @role.save
        format.html { redirect_to(@role, notice: "Role was successfully created.") }
        format.xml { render xml: @role, status: :created, location: @role }
      else
        format.html { render action: "new" }
        format.xml { render xml: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])
    authorize @role, :update?
    respond_to do |format|
      if @role.update_attributes(permitted_params)
        format.html { redirect_to(@role, notice: "Role was successfully updated.") }
        format.xml { head :ok }
      else
        format.html { render action: "edit" }
        format.xml { render xml: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    authorize @role, :destroy?
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml { head :ok }
    end
  end
end
