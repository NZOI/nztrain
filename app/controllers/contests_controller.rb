class ContestsController < ApplicationController
  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name, :start_time, :end_time, :duration, :problem_set_id, :startcode, :observation, :live_scoreboard, :only_rank_official_contestants]
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

    visible_contests = policy_scope(Contest)

    case params[:filter].to_s
    when 'active'
      raise Pundit::NotAuthorizedError unless user_signed_in?
      @contests = Contest.joins(:contest_relations).where{ (contest_relations.user_id == my{current_user.id}) & (contest_relations.finish_at > Time.now) }.order("end_time ASC")
    when 'current'
      @contests = visible_contests.where{(start_time < Time.now+30.minutes) & (end_time > Time.now)}.order("end_time ASC")
    when 'upcoming'
      @contests = visible_contests.where{(start_time > Time.now+30.minutes)}.order("start_time ASC")
    when 'past'
      @contests = visible_contests.where{(end_time < Time.now)}.order("end_time DESC")
    else
      raise Pundit::NotAuthorizedError
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    if !policy(@contest).overview?
      redirect_to scoreboard_contest_path(@contest)
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
    @contest_relation = @contest.get_relation(current_user.id) if user_signed_in?

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
    @contest_relations = @contest.contest_relations.includes(:user).order("contest_relations.school_id, users.username")

    render layout: 'contest'
  end

  def supervisors
    @contest = Contest.find(params[:id])
    authorize @contest, :manage?
    @groups = Group.all
    @contest_supervisors = @contest.contest_supervisors.includes(:user).order("users.username")
    @new_supervisor = ContestSupervisor.new(contest: @contest)

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
    @start_time = @contest.start_time.try(:strftime, "%d/%m/%Y %H:%M")
    @end_time = @contest.end_time.try(:strftime, "%d/%m/%Y %H:%M")
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
    if request.get? # show start code form
    elsif request.put?
      @contest = Contest.find(params[:id])
      authorize @contest, :start?

      if !@contest.startcode.nil? && @contest.startcode != params[:startcode]
        redirect_to(@contest, :alert => 'Incorrect start code.')
        return
      end

      respond_to do |format|
        if @contest.start(current_user, true)
          format.html { redirect_to(@contest, :notice => 'Contest started.') }
        else
          format.html { redirect_to(@contest, :alert => @contest.errors.full_messages_for(:contest).join(' ')) }
        end
      end
    else
      raise "ERROR"
    end
  end

  def register
    @contest = Contest.find(params[:id])

    if request.put?
      authorize @contest, :register?
      user = current_user
      redirect_path = contest_path(@contest)
    elsif request.post?
      user = User.find_by(username: params[:username])
      if params[:contest_supervisor_id]
        @contest_supervisor = ContestSupervisor.find(params[:contest_supervisor_id])
        if @contest_supervisor.user_id != current_user.id || @contest_supervisor.contest_id != @contest.id || !@contest_supervisor.is_user_eligible?(user)
          # details don't match, so check that they can manage contest
          authorize @contest, :register_user?
          raise "ERROR"
        else
          authorize @contest_supervisor, :register?
        end
      else
        authorize @contest, :register_user?
      end
      redirect_path = contestants_contest_path(@contest)
    else
      raise "ERROR"
    end

    respond_to do |format|
      if user.nil?
        format.html { redirect_to(redirect_path, :alert => "No such user exists.") }
      elsif @contest.register(user)
        format.html { redirect_to(redirect_path, :notice => "Registered #{params[:username]} for contest.") }
      else
        format.html { redirect_to(redirect_path, :alert => @contest.errors.full_messages_for(:contest).join(' ')) }
      end
    end
  end

  def supervise
    @contest = Contest.find(params[:id])
    if params[:contest_supervisor] # not really necessary
      @contest_supervisor = @contest.contest_supervisors.find_by_id(params[:contest_supervisor])
      authorize @contest_supervisor, :use?
    end
    if params[:start_contest_all]
      params[:start_contest] = params[:start_contest_all]
      params[:selected] = []
      @contest_supervisor.contest_relations.where(started_at: nil).each do |relation|
        last_seen_at = relation.user.last_seen_at
        params[:selected] << relation.id if last_seen_at && Time.now - last_seen_at < 15.minutes
      end
      params[:selected] = nil if params[:selected].empty?
    end
    if params[:start_contest] && params[:selected]
      if !@contest.is_running?
        redirect_to contestants_contest_path(@contest), :alert => "The contest is not currently running"
        return
      end
      ContestRelation.transaction do
        params[:selected].each do |relation_id|
          relation = @contest.contest_relations.find_by_id(relation_id)
          authorize relation, :supervise?
          relation.supervisor = current_user
          relation.set_start_timer! 1.minute
        end
      end
      redirect_to contestants_contest_path(@contest), :notice => "Contest started for selected students"
    elsif params[:end_contest] && params[:selected]
      ContestRelation.transaction do
        params[:selected].each do |relation_id|
          relation = @contest.contest_relations.find_by_id(relation_id)
          authorize relation, :supervise?
          relation.stop! if relation.started? && !relation.ended?
        end
      end
      redirect_to contestants_contest_path(@contest), :notice => "Contest ended for selected students"
    elsif params[:update]
      if params[:school_id]
        ContestRelation.transaction do
          params[:school_id].each do |relation_id, school_id|
            relation = @contest.contest_relations.find_by_id(relation_id)
            authorize relation, :update_school?
            relation.school = School.find_by_id(school_id)
            if !relation.save
              redirect_to contestants_contest_path(@contest), :alert => "Could not update school of contestant #{relation.user&.username}."
              return
            end
          end
        end
      end
      if params[:extra_time]
        ContestRelation.transaction do
          params[:extra_time].each do |relation_id, extra_time|
            relation = @contest.contest_relations.find_by_id(relation_id)
            authorize relation, :update_extra_time?
            relation.extra_time = extra_time.to_i || 0
            if extra_time.to_i > @contest.max_extra_time
              redirect_to contestants_contest_path(@contest), :alert => "The maximum extra time that can be given is #{@contest.max_extra_time}."
              return
            end
            if !relation.save
              redirect_to contestants_contest_path(@contest), :alert => "Could not add extra time to contestant #{relation.user&.username}."
              return
            end
          end
        end
      end
      if params[:school_id] || params[:extra_time]
        redirect_to contestants_contest_path(@contest), :notice => "Contestants updated"
      else
        redirect_to contestants_contest_path(@contest), :alert => "Nothing to update."
        return
      end
    else
      redirect_to contestants_contest_path(@contest), :alert => "Could not start/end contest for any users as none were selected."
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

  def export
    @contest = Contest.find(params[:id])
    authorize @contest, :update?
    name = @contest.name.gsub(/[\W]/,"")
    name = "contest" if name.empty?
    filename = name + ".zip"

    dir = Dir.mktmpdir("zip-contest-#{@contest.id}-#{current_user.id}-#{Time.now}")
    zipfile = Contests::ContestExporter.export(@contest, File.expand_path(filename, dir))

    send_file zipfile, :type => 'application/zip', :disposition => 'attachment', :filename => filename
  end

end
