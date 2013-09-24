class GroupsController < ApplicationController
  #load_and_authorize_resource :except => [:create]
  #skip_load_and_authorize_resource :only => [:add_contest]
  filter_resource_access :additional_collection => { :browse => :index }, :additional_member => { :show => :index, :info => :index, :contests => :access_problems, :members => :access_problems }

  def permitted_params
    @_permitted_attributes ||= begin
      permitted_attributes = [:name]
      permitted_attributes << :owner_id if permitted_to? :transfer, @group
      permitted_attributes
    end
    params.require(:group).permit(*@_permitted_attributes)
  end

  def new_group_from_params
    @group = Group.new(:owner => current_user)
  end

  def join
    permitted_to! :join, @group
    if @group.users.exists?(current_user)
      redirect_to(@group, :alert => "You are already a member of this group")
      return
    end
    @group.users.push(current_user)
    redirect_to(@group, :notice => "You are now a member of this group")
  end

  def leave
    permitted_to! :leave, @group
    @group.users.delete(current_user)
    redirect_to(@group, :notice => "You are no longer a member of this group")
  end
  def add_problem_set # not currently used (setup like problem_problem_sets_controller method, other way is to setup like the add_contest method)
    @group = Group.find(params[:problem_set][:group_ids])
    permitted_to! :update, @group
    problem_set = ProblemSet.find(params[:problem_set_id])
    permitted_to! :use, problem_set # cannot add problem sets without use permission
    if @group.problem_sets.exists?(problem_set)
      redirect_to(problem, :alert => "This group already has access to this problem set")
      return
    end
    @group.problem_sets.push(problem_set)
    redirect_to(problem_set, :notice => "Problem set added.")
  end

  def remove_problem_set
    permitted_to! :update, @group
    problem_set = ProblemSet.find(params[:problem_set_id])
    @group.problem_sets.delete(problem_set)
    redirect_to(@group, :notice => "Problem set removed.")
  end

  def add_contest
    @group = Group.find(params[:contest][:group_ids])
    permitted_to! :update, @group
    contest = Contest.find(params[:contest_id])
    permitted_to! :use, contest # cannot add contests without use permission
    if @group.contests.exists?(contest)
      redirect_to(contest, :alert => "This group already has access to this contest")
      return
    end
    @group.contests.push(contest)
    redirect_to(contest, :notice => "Contest added.")
  end

  def remove_contest
    permitted_to! :update, @group
    contest = Contest.find(params[:contest_id])
    @group.contests.delete(contest)
    redirect_to(@group, :notice => "Contest removed.")
  end

  # GET /groups
  # GET /groups.xml
  def index
    case params[:filter].to_s
    when 'my'
      permitted_to! :manage, Group.new(:owner_id => current_user.id)
      @groups = Group.where(:owner_id => current_user.id)
    else
      permitted_to! :manage, Group.new
      @groups = Group.scoped
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def browse
    @groups = Group.scoped

    render 'index'
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    if permitted_to? :access_problems, @group
      @problem_sets = @group.problem_sets
      render :layout => "group"
    else
      redirect_to info_group_path(@group)
    end
  end

  def contests
    @contests = @group.contests
    respond_to do |format|
      format.html { render :layout => "group" }
    end
  end
  
  def info 
    respond_to do |format|
      format.html { render :layout => "group" }
    end
  end

  def members
    @users = @group.users
    render :layout => "group"
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.xml
  def create
    respond_to do |format|
      if @group.update_attributes(permitted_params)
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
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
