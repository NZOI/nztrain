class NZIC::InfoController < ApplicationController
  helper NZIC::InfoHelper
  #helper 'nzic/info'

  def permitted_params
    params.require(:nzic_info).permit(:name, :text)
  end

  def index
    authorize NZIC::Info, :index?
    @infos = policy_scope(NZIC::Info).order(:name)
  end

  def show
    @info = NZIC::Info.find(params[:name])
    authorize @info, :show?
  end

  def new
    @info = NZIC::Info.new
    authorize @info, :new?
  end

  def create
    @info = NZIC::Info.new(permitted_params)
    authorize @info, :create?

    respond_to do |format|
      if @info.save
        format.html { redirect_to @info, notice: "Info page created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @info = NZIC::Info.find(params[:name])
    authorize @info, :edit?
  end

  def update
    @info = NZIC::Info.find(params[:name])
    authorize @info, :update?

    respond_to do |format|
      if @info.update_attributes(permitted_params)
        format.html { redirect_to @info, notice: "Info page updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @info = NZIC::Info.find(params[:name])
    authorize @info, :destroy?
    @info.destroy

    respond_to do |format|
      format.html { redirect_to nzic_info_path, notice: "NZIC info page destroyed." }
    end
  end
end
