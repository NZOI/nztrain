class ContestsController < ApplicationController
  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name, :start_time, :end_time, :duration, :problem_set_id]
      permitted_attributes << :owner_id if policy(@contest || Contest).transfer?
      params.require(:contest).permit(*permitted_attributes)
    end
  end

  # GET /contests
  # GET /contests.xml
  def index
    case params[:filter].to_s
    when 'my'
      authorize Contest.new(:owner_id => current_user.id), :manage?
      @contests = Contest.where(:owner_id => current_user.id).order("end_time DESC")
    else
      authorize Contest.new, :manage?
      @contests = Contest.order("end_time DESC")
    end
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def browse
    authorize Contest, :index?
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
      raise Pundit::NotAuthorizedError
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    if !policy(@contest).overview?
      redirect_to info_contest_path(@contest)
      return
    end
    @problem_associations = @contest.problem_set.problem_associations.includes(:problem)
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
    @contest = Contest.find(params[:id])
    authorize @contest, :show?
    @groups = Group.all
    render :layout => 'contest'
  end

  def scoreboard
    @contest = Contest.find(params[:id])
    authorize @contest, :scoreboard?
    @groups = Group.all
    @problems = @contest.problem_set.problems
    @weighting = Hash[@contest.problem_associations.pluck(:problem_id, :weighting)]
    @realtimejudging = true # if false, scores only revealed at the end
    @scoreboard = @contest.scoreboard

    render :layout => 'contest'
  end

  def contestants
    @contest = Contest.find(params[:id])
    authorize @contest, :contestants?
    @groups = Group.all
    @contest_relations = @contest.contest_relations.includes(:user)

    render layout: 'contest'
  end

  # GET /contests/new
  # GET /contests/new.xml
  def new
    @contest = Contest.new(:owner => current_user)
    authorize @contest, :new?
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
    @contest = Contest.find(params[:id])
    authorize @contest, :edit?
    @problem_sets = ProblemSet.all
    @start_time = @contest.start_time.strftime("%d/%m/%Y %H:%M")
    @end_time = @contest.end_time.strftime("%d/%m/%Y %H:%M")
  end

  # POST /contests
  # POST /contests.xml
  def create
    @contest = Contest.new(permitted_params)
    @contest.owner ||= current_user
    authorize @contest, :create?
    authorize ProblemSet.find(params[:contest][:problem_set_id]), :use? if params[:contest][:problem_set_id]

    params[:contest][:start_time] = Time.zone.parse(params[:contest][:start_time])
    params[:contest][:end_time] = Time.zone.parse(params[:contest][:end_time])

    logger.debug "time zone is " + Time.zone.to_s

    respond_to do |format|
      if @contest.save
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
    @contest = Contest.find(params[:id])
    authorize @contest, :update?
    authorize ProblemSet.find(params[:contest][:problem_set_id]), :use? if params[:contest][:problem_set_id] && (params[:contest][:problem_set_id] != @contest.problem_set_id) # can only use problem sets which user has permission to use

    params[:contest][:start_time] = Time.zone.parse(params[:contest][:start_time])
    params[:contest][:end_time] = Time.zone.parse(params[:contest][:end_time])

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
    @contest = Contest.find(params[:id])
    authorize @contest, :destroy?
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to(contests_url) }
      format.xml  { head :ok }
    end
  end

  def start
    @contest = Contest.find(params[:id])
    authorize @contest, :start?

    respond_to do |format|
      if @contest.start(current_user.id)
        format.html { redirect_to(@contest, :notice => 'Contest started.') }
      else
        format.html { redirect_to(@contest, :alert => @contest.errors.full_messages_for(:contest).join(' ')) }
      end
    end
  end

  def finalize
    @contest = Contest.find(params[:id])
    authorize @contest, :finalize?
    @contest.finalized_at = Time.now
    @contest.save
    redirect_to contest_path(@contest), :notice => "Contest results finalized"
  end

  def unfinalize
    @contest = Contest.find(params[:id])
    authorize @contest, :unfinalize?
    @contest.finalized_at = nil
    @contest.save
    redirect_to contest_path(@contest), :notice => "Contest results unfinalized"
  end

end
