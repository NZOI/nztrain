class SchoolsController < ApplicationController

  def index
    authorize School.new, :index?
    @schools = School.all
  end

  def show
    @school = School.find(params[:id])
    authorize @school, :show?
  end

  private
end
