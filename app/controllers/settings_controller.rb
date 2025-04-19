class SettingsController < ApplicationController
  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:key, :value]
      params.require(:setting).permit(*permitted_attributes)
    end
  end

  # GET /settings
  # GET /settings.xml
  def index
    authorize Setting.new, :index?
    @settings = policy_scope(Setting)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @settings }
    end
  end

  # GET /settings/1
  # GET /settings/1.xml
  def show
    @setting = Setting.find(params[:id])
    authorize @setting, :show?
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render xml: @setting }
    end
  end

  # GET /settings/new
  # GET /settings/new.xml
  def new
    @setting = Setting.new
    authorize @setting, :new?
    respond_to do |format|
      format.html # new.html.erb
      format.xml { render xml: @setting }
    end
  end

  # GET /settings/1/edit
  def edit
    @setting = Setting.find(params[:id])
    authorize @setting, :edit?
  end

  # POST /settings
  # POST /settings.xml
  def create
    @setting = Setting.new(permitted_params)
    authorize @setting, :new?
    respond_to do |format|
      if @setting.save
        format.html { redirect_to(@setting, notice: "Setting was successfully created.") }
        format.xml { render xml: @setting, status: :created, location: @setting }
      else
        format.html { render action: "new" }
        format.xml { render xml: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /settings/1
  # PUT /settings/1.xml
  def update
    @setting = Setting.find(params[:id])
    authorize @setting, :update?
    respond_to do |format|
      if @setting.update_attributes(permitted_params)
        format.html { redirect_to(@setting, notice: "Setting was successfully updated.") }
        format.xml { head :ok }
      else
        format.html { render action: "edit" }
        format.xml { render xml: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/1
  # DELETE /settings/1.xml
  def destroy
    @setting = Setting.find(params[:id])
    authorize @setting, :destroy?
    @setting.destroy

    respond_to do |format|
      format.html { redirect_to(settings_url) }
      format.xml { head :ok }
    end
  end
end
