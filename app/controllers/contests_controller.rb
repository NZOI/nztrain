class ContestsController < ApplicationController
  filter_resource_access :additional_collection => {:browse => :index}, :additional_member => [:start, :finalize, :unfinalize, [:info, :show], :scoreboard]

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:title, :start_time, :end_time, :duration, :problem_set_id]
      permitted_attributes << :owner_id if permitted_to? :transfer, @contest
      params.require(:contest).permit(*permitted_attributes)
    end
  end

  def new_contest_from_params
    @contest = Contest.new(:owner => current_user)
  end

  # GET /contests
  # GET /contests.xml
  def index
    case params[:filter].to_s
    when 'my'
      permitted_to! :manage, Contest.new(:owner_id => current_user.id)
      @contests = Contest.where(:owner_id => current_user.id).order("end_time DESC")
    else
      permitted_to! :manage, Contest.new
      @contests = Contest.order("end_time DESC")
    end
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def browse
    groups_contests = Contest.joins(:groups => :members).where{(groups.id == 0) | (groups.members.id == my{current_user.id})}.distinct
    case params[:filter].to_s
    when 'active'
      @contests = Contest.joins(:contest_relations).where{ (contest_relations.user_id == my{current_user.id}) & (contest_relations.finish_at > Time.now) }.order("end_time ASC")
    when 'current'
      @contests = groups_contests.where{(start_time < Time.now+30.minutes) & (end_time > Time.now)}.order("end_time ASC")
    when 'upcoming'
      @contests = groups_contests.where{(start_time > Time.now+30.minutes)}.order("start_time ASC")
    when 'past'
      @contests = groups_contests.where{(end_time < Time.now)}.order("end_time DESC")
    else
      raise Authorization::AuthorizationError
    end

  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    if !permitted_to? :access_problems, @contest
      redirect_to info_contest_path(@contest)
      return
    end
    @problems = @contest.problem_set.problems
    @groups = Group.all
    @contest_message = nil
    if @contest.get_relation(current_user) && !@contest.has_current_competitor?(current_user)
      @contest_message = "Your time slot is over and you can no longer submit for this contest."
    elsif @contest.is_running? && !@contest.get_relation(current_user)
      @contest_message = "You have not started this contest."
    end

    render :layout => 'contest'
  end

  def info
    @groups = Group.all
    render :layout => 'contest'
  end

  def scoreboard
    @groups = Group.all
    @problems = @contest.problem_set.problems
    @realtimejudging = true # if false, scores only revealed at the end
    @scoreboard = @contest.scoreboard

    render :layout => 'contest'
  end

  # GET /contests/new
  # GET /contests/new.xml
  def new
    @problem_sets = ProblemSet.all
    @start_time = ""
    @end_time = ""

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/1/edit
  def edit
    @problem_sets = ProblemSet.all
    @start_time = @contest.start_time.strftime("%d/%m/%Y %H:%M")
    @end_time = @contest.end_time.strftime("%d/%m/%Y %H:%M")
  end

  # POST /contests
  # POST /contests.xml
  def create
    permitted_to! :use, params[:contest][:problem_set_id] if params[:contest][:problem_set_id]

    params[:contest][:start_time] = params[:contest][:start_time].get_date(Time.zone)
    params[:contest][:end_time] = params[:contest][:end_time].get_date(Time.zone)

    logger.debug "time zone is " + Time.zone.to_s

    respond_to do |format|
      if @contest.update_attributes(permitted_params)
        format.html { redirect_to(@contest, :notice => 'Contest was successfully created.') }
        format.xml  { render :xml => @contest, :status => :created, :location => @contest }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contests/1
  # PUT /contests/1.xml
  def update
    permitted_to! :use, ProblemSet.find(params[:contest][:problem_set_id]) if params[:contest][:problem_set_id] && (params[:contest][:problem_set_id] != @contest.problem_set_id) # can only use problem sets which user has permission to use

    params[:contest][:start_time] = params[:contest][:start_time].get_date(Time.zone)
    params[:contest][:end_time] = params[:contest][:end_time].get_date(Time.zone)

    respond_to do |format|
      if @contest.update_attributes(permitted_params)
        format.html { redirect_to(@contest, :notice => 'Contest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contests/1
  # DELETE /contests/1.xml
  def destroy
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to(contests_url) }
      format.xml  { head :ok }
    end
  end

  def start
    @contest_relation = ContestRelation.new

    #TODO: check that no relation already exists
    if ContestRelation.find(:first, :conditions => ["user_id = ? and contest_id = ?", current_user, @contest])
      redirect_to(@contest, :alert => "You have already started this contest!")
      return
    end

    if !@contest.is_running?
      redirect_to(contests_url, :alert => "This contest is not currently running.")
      return
    end

    @contest_relation.user = current_user
    @contest_relation.started_at = DateTime.now
    @contest_relation.contest = @contest

    respond_to do |format|
      if @contest_relation.save
        format.html { redirect_to(@contest, :notice => 'Contest started.') }
        format.xml  { render :xml => @contest_relation, :status => :created, :location => @contest_relation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contest_relation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def finalize
    @contest.finalized_at = Time.now
    @contest.save
    redirect_to contest_path(@contest), :notice => "Contest results finalized"
  end

  def unfinalize
    @contest.finalized_at = nil
    @contest.save
    redirect_to contest_path(@contest), :notice => "Contest results unfinalized"
  end

end
