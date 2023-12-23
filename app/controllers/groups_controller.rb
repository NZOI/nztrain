class GroupsController < ApplicationController

  def permitted_params
    @_permitted_attributes ||= begin
      permitted_attributes = [:name, :visibility, :membership]
      permitted_attributes << :owner_id if policy(@group || Group).transfer?
      permitted_attributes
    end
    params.require(:group).permit(*@_permitted_attributes)
  end

  def add_contest
    @group = Group.find(params[:contest][:group_ids])
    authorize @group, :update?
    @contest = Contest.find(params[:contest_id])
    authorize @contest, :use?
    if @group.contests.exists?(@contest.id)
      redirect_to(@contest, :alert => "This group already has access to this contest")
      return
    end
    @group.contests.push(@contest)
    redirect_to(@contest, :notice => "Contest added.")
  end

  def remove_contest
    @group = Group.find(params[:id])
    authorize @group, :update?
    contest = Contest.find(params[:contest_id])
    @group.contests.delete(contest)
    redirect_to(@group, :notice => "Contest removed.")
  end

  # GET /groups
  # GET /groups.xml
  def index
    case params[:filter].to_s
    when 'my'
      authorize Group.new(:owner_id => current_user.id), :update?
      @groups = Group.where(:owner_id => current_user.id)
    else
      authorize Group.new, :update?
      @groups = Group.all
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def browse
    @groups = Group.where(:visibility => Group::VISIBILITY[:public])

    render 'index'
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])
    if policy(@group).access?
      @problem_set_associations = @group.problem_set_associations
      render :layout => "group"
    else
      redirect_to info_group_path(@group)
    end
  end

  def contests
    @group = Group.find(params[:id])
    authorize @group, :access?
    @contests = @group.contests
    respond_to do |format|
      format.html { render :layout => "group" }
    end
  end

  def info
    @group = Group.find(params[:id])
    authorize @group, :show?
    respond_to do |format|
      format.html { render :layout => "group" }
    end
  end

  def scoreboard
    @group = Group.find(params[:id])
    authorize @group, :access?
    @problem_set_associations = @group.problem_set_associations

    problem_ids = ProblemSetProblem.where(:problem_set_id => GroupProblemSet.where(:group_id => @group.id).select(:problem_set_id)).select(:problem_id)
    @members = @group.members

    @scores = {}
    @members.each { |member| @scores[member.id] ||= {} }
    UserProblemRelation.where(:user_id => GroupMembership.where(:group_id => @group.id).select(:member_id), :problem_id => problem_ids).each do |relation|
      @scores[relation.user_id][relation.problem_id] = relation
    end

    respond_to do |format|
      format.html { render :layout => "group" }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new(:owner => current_user)
    authorize @group, :new?
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    authorize @group, :edit?
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(permitted_params)
    @group.owner ||= current_user
    authorize @group, :create?
    respond_to do |format|
      if @group.save
        format.html { redirect_to(@group, :notice => 'Group was successfully created.') }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])
    authorize @group, :update?
    respond_to do |format|
      if @group.update_attributes(permitted_params)
        format.html { redirect_to(@group, :notice => 'Group was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    authorize @group, :destroy?
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(browse_groups_url) }
      format.xml  { head :ok }
    end
  end
end
