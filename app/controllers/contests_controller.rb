class ContestsController < ApplicationController
  before_filter :check_signed_in
  before_filter :check_access, :only => [:show]
  before_filter :check_admin, :only => [:edit, :create, :update, :destroy]

  def check_access
    @contest = Contest.find(params[:id])

    if !@contest.can_be_viewed_by(current_user)
      redirect_to(contests_path, :alert => "You do not have access to this contest!")
    end
  end
  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.all
    @contests = @contests.find_all {|c| c.can_be_viewed_by(current_user)}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contests }
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    @problems = @contest.problems
    @groups = Group.all
    @contest_message = nil

    respond_to do |format|
      if !@contest.is_running?
        #render contest report page
        @high_scorers = @contest.get_high_scorers
        logger.debug @high_scorers

        format.html { render "report" }
        format.xml  { render :xml => @contest }
      elsif current_user.is_admin || @contest.has_current_competitor(current_user)
        #render proper contest page
        format.html
        format.xml  { render :xml => @contest }
      elsif @contest.get_relation(current_user)
        #user has finished contest. render contest page, but with a message saying "you're done"
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
    @problems = @contest.problems
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
