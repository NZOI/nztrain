class ContestsController < ApplicationController
  before_filter :check_signed_in
  load_and_authorize_resource

  def check_access
    @contest = Contest.find(params[:id])

    if !@contest.can_be_viewed_by(current_user)
      redirect_to(contests_path, :alert => "You do not have access to this contest!")
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
    if @realtimejudging
      @scoreboard = Submission.find_by_sql("SELECT * FROM contests_max_score_scoreboard WHERE contest_id = #{params[:id]}")
      @scores = Submission.find_by_sql("SELECT * FROM contests_max_score_submissions WHERE contest_id = #{params[:id]}")
    else
      @scoreboard = Submission.find_by_sql("SELECT * FROM contests_latest_scoreboard WHERE contest_id = #{params[:id]}")
      @scores = Submission.find_by_sql("SELECT * FROM contests_latest_submissions WHERE contest_id = #{params[:id]}")
    end
    @sub_count = Submission.find_by_sql("SELECT * FROM contests_count_submissions WHERE contest_id = #{params[:id]}")
    @scoredetails = Hash.new({})
    @scores.each do |s|
      @scoredetails[[s[:user_id],s[:problem_id]]] = {:score => s[:score], :sub_id => s[:id], :count => 0}
    end
    @sub_count.each do |s|
      @scoredetails[[s[:user_id],s[:problem_id]]][:count] = s[:count]
    end
    if @scoreboard.length>0 && !@scoreboard[0][:rank] # SQLite3 doesn't have Rank() Windowing function
      @scoreboard.each_with_index do |row, i|
        @scoreboard[i][:time_taken] = Time.at(12*3600+row[:time_taken].to_i).strftime('%H:%M:%S')
      end
      @current_rank = 0
      @scoreboard.each_with_index do |row, i|
        if i==0 || (row[:total_score].to_i < @scoreboard[i-1][:total_score].to_i) || (row[:total_score].to_i  == @scoreboard[i-1][:total_score].to_i  && row[:time_taken]  > @scoreboard[i-1][:time_taken] )
          @current_rank = i+1;
        end
        @scoreboard[i][:rank] = @current_rank
      end
    end
    if cannot? :manage, @contest
      @median = @scoreboard[@scoreboard.length/2][:rank].to_i
      @scoreboard = @scoreboard.reject{|row| (row[:rank].to_i >= @median && row[:user_id] != current_user.id)}
    end
    respond_to do |format|
      if current_user.is_admin || !@contest.is_running?
        #render contest report page
        #@high_scorers = @contest.get_high_scorers(current_user.is_admin)
        #logger.debug @high_scorers

        format.html { render "report" }
        format.xml  { render :xml => @contest }
      elsif @contest.has_current_competitor(current_user)
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
    @contest = Contest.new
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
    #@problems = @contest.problem_set.problems
    @problem_sets = ProblemSet.all
    @start_time = @contest.start_time.strftime("%m/%d/%Y %H:%M")
    @end_time = @contest.end_time.strftime("%m/%d/%Y %H:%M")
  end

  # POST /contests
  # POST /contests.xml
  def create
    @contest = Contest.new(params[:contest])
    @contest.start_time = params[:contest][:start_time].get_date(Time.zone)
    @contest.end_time = params[:contest][:end_time].get_date(Time.zone)
    logger.debug "time zone is " + Time.zone.to_s
    @contest.user_id = current_user

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
    authorize! :use, params[:contest][:problem_set_id] if params[:contest][:problem_set] # can only use problem sets which user has permission to use
    params[:contest][:start_time] = params[:contest][:start_time].get_date(Time.zone)
    params[:contest][:end_time] = params[:contest][:end_time].get_date(Time.zone)
    @contest = Contest.find(params[:id])

    respond_to do |format|
      if @contest.update_attributes(params[:contest])
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
end
