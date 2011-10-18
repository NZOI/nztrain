class ContestsController < ApplicationController
  before_filter :check_signed_in
  before_filter :check_access, :only => [:show]
  before_filter :check_admin, :only => [:edit, :create, :update, :destroy]

  def check_access
    @contest = Contest.find(params[:id])

    if !@contest.allows(current_user)
      redirect_to(contests_path, :alert => "You do not have access to this contest!")
    end
  end
  # GET /contests
  # GET /contests.xml
  def index
    
    @contests = Contest.all

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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/new
  # GET /contests/new.xml
  def new
    @contest = Contest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
    @problems = @contest.problems
  end

  # POST /contests
  # POST /contests.xml
  def create
    logger.debug params[:contest][:start_time].get_date
    logger.debug params[:contest][:end_time].get_date
    params[:contest][:start_time] = params[:contest][:start_time].get_date
    params[:contest][:end_time] = params[:contest][:end_time].get_date
    @contest = Contest.new(params[:contest])
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
    params[:contest][:start_time] = params[:contest][:start_time].get_date
    params[:contest][:end_time] = params[:contest][:end_time].get_date
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
