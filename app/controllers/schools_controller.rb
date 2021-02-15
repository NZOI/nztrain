class SchoolsController < ApplicationController

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name]
      params.require(:school).permit(*permitted_attributes)
    end
  end

  def index
    authorize School.new, :index?
    @schools = School.order(name: :asc)
  end

  def show
    @school = School.find(params[:id])
    authorize @school, :show?
  end

  def edit
    @school = School.find(params[:id])
    authorize @school, :edit?
  end

  def update
    @school = School.find(params[:id])
    authorize @school, :update?
    if @school.update_attributes(permitted_params)
      redirect_to @school, :notice => "School was successfully updated."
    else
      render :action => "edit"
    end
  end

  def destroy
    @school = School.find(params[:id])
    authorize @school, :destroy?
    if @school.users.any?
      redirect_to :back, :alert => "Could not destroy school, as one or more users belong to it."
    elsif (relation = ContestRelation.find_by(school_id: @school.id))
      redirect_to contestants_contest_path(relation.contest), :alert => "Could not destroy school, as one or more contest relations belong to it."
    else
      @school.destroy
      redirect_to schools_url
    end
  end

  private
end
