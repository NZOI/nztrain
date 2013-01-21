class ContestsController < ApplicationController
  load_and_authorize_resource :except => [:create]

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:title, :start_time, :end_time, :duration, :problem_set_id]
      permitted_attributes << :owner_id if can? :transfer, @contest
      params.require(:contest).permit(*permitted_attributes)
    end
  end

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.accessible_by(current_ability).distinct

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contests }
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    @problems = @contest.problem_set.problems
    @groups = Group.all
    @contest_message = nil
    
    @realtimejudging = true # if false, scores only revealed at the end
    @scoreboard = @contest.scoreboard

    respond_to do |format|
      if current_user.is_admin? || !@contest.is_running?
        format.html { render "report" }
        format.xml  { render :xml => @contest }
      elsif @contest.has_current_competitor?(current_user)
        @contest_relation = @contest.get_relation(current_user)
        #render proper contest page
        format.html
        format.xml  { render :xml => @contest }
      elsif @contest.get_relation(current_user)
        #user has finished contest. render contest page, but with a message saying "you're done"
        @contest_relation = @contest.get_relation(current_user)
        logger.debug "got finished contest\n"
        @contest_message = "Your time slot is over and you can no longer submit for this contest."

        format.html 
        format.xml  { render :xml => @contest }
      else
        #redirect, user doesn't have access
        redirect("You have not started this contest.")
      end
    end
  end

  # GET /contests/new
  # GET /contests/new.xml
  def new
    @contest.owner_id = current_user.id
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
    @contest = Contest.new(:owner_id => current_user.id)
    authorize! :create, @contest
    authorize! :use, params[:contest][:problem_set_id] if params[:contest][:problem_set_id]

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
    authorize! :use, params[:contest][:problem_set_id] if params[:contest][:problem_set_id] && (params[:contest][:problem_set_id] != @contest.problem_set_id) # can only use problem sets which user has permission to use

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
    @contest = Contest.find(params[:id])
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to(contests_url) }
      format.xml  { head :ok }
    end
  end

  def start
    @contest_relation = ContestRelation.new
    @contest = Contest.find(params[:id])

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
