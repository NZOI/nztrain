class ContestSupervisorsController < ApplicationController
  # filter_resource_access

  def permitted_params
    permitted_attributes = [:username, :contest_id, :site_type, :site_id]
    params.require(:contest_supervisor).permit(*permitted_attributes)
  end

  def update_scheduled_time
    @contest_supervisor = ContestSupervisor.find(params[:id])
    authorize @contest_supervisor, :use?
    @contest_supervisor.assign_attributes(params.require(:contest_supervisor).permit(:scheduled_start_time))

    if @contest_supervisor.save
      redirect_to(contestants_contest_path(@contest_supervisor.contest), notice: "Scheduled start time updated.")
    else
      redirect_to(contestants_contest_path(@contest_supervisor.contest), alert: "Error, could not update scheduled start time")
    end
  end

  def create
    @contest_supervisor = ContestSupervisor.new(permitted_params)
    authorize @contest_supervisor, :create?

    if @contest_supervisor.save
      redirect_to(supervisors_contest_path(@contest_supervisor.contest), notice: "Contest supervisor was successfully created.")
    else
      @contest = @contest_supervisor.contest
      @contest_supervisors = @contest.contest_supervisors
      @new_supervisor = @contest_supervisor
      @groups = @contest.groups
      render template: "contests/supervisors", layout: "contest"
    end
  end

  def destroy
    @contest_supervisor = ContestSupervisor.find(params[:id])

    authorize @contest_supervisor, :destroy?

    if @contest_supervisor.destroy
      redirect_to(supervisors_contest_path(@contest_supervisor.contest), notice: "Contest supervisor deleted")
    else
      redirect_to(supervisors_contest_path(@contest_supervisor.contest), alert: "Could not delete contest supervisor")
    end
  end
end
