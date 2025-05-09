class GroupsController < ApplicationController
  def permitted_params
    permitted_attributes = [:name, :visibility, :membership]
    permitted_attributes << :owner_id if policy(@group || Group).transfer?
    params.require(:group).permit(*permitted_attributes)
  end

  def add_contest
    @group = Group.find(params[:contest][:group_ids])
    authorize @group, :update?
    @contest = Contest.find(params[:contest_id])
    authorize @contest, :use?
    if @group.contests.exists?(@contest.id)
      redirect_to(@contest, alert: "This group already has access to this contest")
      return
    end
    @group.contests.push(@contest)
    redirect_to(@contest, notice: "Contest added.")
  end

  def remove_contest
    @group = Group.find(params[:id])
    authorize @group, :update?
    contest = Contest.find(params[:contest_id])
    @group.contests.delete(contest)
    redirect_to(@group, notice: "Contest removed.")
  end

  def index
    case params[:filter].to_s
    when "my"
      authorize Group.new(owner_id: current_user.id), :update?
      @groups = Group.where(owner_id: current_user.id)
    else
      authorize Group.new, :update?
      @groups = Group.all
    end
  end

  def browse
    @groups = Group.where(visibility: Group::VISIBILITY[:public])

    render "index"
  end

  def show
    @group = Group.find(params[:id])
    if policy(@group).access?
      @problem_set_associations = @group.problem_set_associations
      render layout: "group"
    else
      redirect_to info_group_path(@group)
    end
  end

  def contests
    @group = Group.find(params[:id])
    authorize @group, :access?

    @contests = @group.contests
    render layout: "group"
  end

  def info
    @group = Group.find(params[:id])
    authorize @group, :show?

    render layout: "group"
  end

  def scoreboard
    @group = Group.find(params[:id])
    authorize @group, :access?
    @problem_set_associations = @group.problem_set_associations

    problem_ids = ProblemSetProblem.where(problem_set_id: GroupProblemSet.where(group_id: @group.id).select(:problem_set_id)).select(:problem_id)
    @members = @group.members

    @scores = {}
    @members.each { |member| @scores[member.id] ||= {} }
    UserProblemRelation.where(user_id: GroupMembership.where(group_id: @group.id).select(:member_id), problem_id: problem_ids).each do |relation|
      @scores[relation.user_id][relation.problem_id] = relation
    end

    render layout: "group"
  end

  def new
    @group = Group.new(owner: current_user)
    authorize @group, :new?
  end

  def edit
    @group = Group.find(params[:id])
    authorize @group, :edit?
  end

  def create
    @group = Group.new(permitted_params)
    @group.owner ||= current_user
    authorize @group, :create?

    if @group.save
      redirect_to(@group, notice: "Group was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @group = Group.find(params[:id])
    authorize @group, :update?

    if @group.update_attributes(permitted_params)
      redirect_to(@group, notice: "Group was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @group = Group.find(params[:id])
    authorize @group, :destroy?
    @group.destroy

    redirect_to(browse_groups_url)
  end
end
