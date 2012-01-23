class GroupsController < ApplicationController
  before_filter :check_signed_in
  load_and_authorize_resource

  def join
    @group = Group.find(params[:id])
    authorize! :join, @group
    if @group.users.exists?(current_user)
      redirect_to(@group, :alert => "You are already a member of this group")
      return
    end
    @group.users.push(current_user)
    redirect_to(@group, :notice => "You are now a member of this group")
  end

  def leave
    @group = Group.find(params[:id])
    authorize! :leave, @group
    @group.users.delete(current_user)
    redirect_to(@group, :notice => "You are no longer a member of this group")
  end
  def add_problem_set
    @group = Group.find(params[:problem_set][:group_ids])
    authorize! :update, @group
    problem_set = ProblemSet.find(params[:problem_set_id])
    authorize! :use, problem_set # cannot add problem sets without use permission
    if @group.problem_sets.exists?(problem_set)
      redirect_to(problem, :alert => "This group already has access to this problem set")
      return
    end
    @group.problem_sets.push(problem_set)
    redirect_to(problem_set, :notice => "Problem set added.")
  end

  def remove_problem_set
    @group = Group.find(params[:id])
    authorize! :update, @group
    problem_set = ProblemSet.find(params[:problem_set_id])
    @group.problem_sets.delete(problem_set)
    redirect_to(@group, :notice => "Problem set removed.")
  end

  def add_contest
    @group = Group.find(params[:contest][:group_ids])
    authorize! :update, @group
    contest = Contest.find(params[:contest_id])
    authorize! :use, contest # cannot add contests without use permission
    if @group.contests.exists?(contest)
      redirect_to(contest, :alert => "This group already has access to this contest")
      return
    end
    @group.contests.push(contest)
    redirect_to(contest, :notice => "Contest added.")
  end

  def remove_contest
    @group = Group.find(params[:id])
    authorize! :update, @group
    contest = Contest.find(params[:contest_id])
    @group.contests.delete(contest)
    redirect_to(@group, :notice => "Contest removed.")
  end

  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.accessible_by(current_ability).distinct

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

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

    respond_to do |format|
      if @group.update_attributes(params[:group])
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
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
