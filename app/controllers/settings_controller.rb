class SettingsController < ApplicationController
  def permitted_params
    permitted_attributes = [:key, :value]
    params.require(:setting).permit(*permitted_attributes)
  end

  def index
    authorize Setting.new, :index?
    @settings = policy_scope(Setting)
  end

  def show
    @setting = Setting.find(params[:id])
    authorize @setting, :show?
  end

  def new
    @setting = Setting.new
    authorize @setting, :new?
  end

  def edit
    @setting = Setting.find(params[:id])
    authorize @setting, :edit?
  end

  def create
    @setting = Setting.new(permitted_params)
    authorize @setting, :new?

    if @setting.save
      redirect_to(@setting, notice: "Setting was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @setting = Setting.find(params[:id])
    authorize @setting, :update?

    if @setting.update_attributes(permitted_params)
      redirect_to(@setting, notice: "Setting was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @setting = Setting.find(params[:id])
    authorize @setting, :destroy?

    @setting.destroy!

    redirect_to(settings_url)
  end
end
