class AiContestsController < ApplicationController
  # GET /ai_contests
  # GET /ai_contests.json

  filter_resource_access :additional_member => {:sample => :show, :submit => :show, :submissions => :show, :judge => :judge, :rejudge => :rejudge}

  def new_ai_contest_from_params
    @ai_contest = AiContest.new(:owner_id => current_user.id)
  end

  def index
    #@ai_contests = AiContest.accessible_by(current_ability)

    respond_to do |format|
      format.html # index.html.erb
      #format.json { render json: @ai_contests }
    end
  end

  # GET /ai_contests/1
  # GET /ai_contests/1.json
  def show
    respond_to do |format|
      format.html { render :layout => "ai_contest" }
      #format.json { render json: @ai_contest }
    end
  end

  def sample
    respond_to do |format|
      format.html { render :layout => "ai_contest" }
      #format.json { render json: @ai_contest }
    end
  end

  def submit
    if request.post? # post request
      @ai_contest = AiContest.find(params[:id]) 
      permitted_to! :submit, @ai_contest # make sure user can submit to this problem
      @ai_submission = AiSubmission.new(submit_params) # create submission
      respond_to do |format|
        if @ai_submission.submit
          Rails.env == 'test' ? @submission.judge : spawn { @submission.judge }
          format.html { redirect_to(@ai_contest, :notice => 'Submission was successfully created.') }
          #format.xml  { render :xml => @submission, :status => :created, :location => @submission }
        else
          format.html { render :action => "show", :alert => 'Submission failed.' }
          #format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
        end
      end
    else # get request
      @ai_contest = AiContest.find(params[:id])
      permitted_to! :submit, @ai_contest
      @ai_submission = AiSubmission.new
      respond_to do |format|
        format.html { render :layout => "ai_contest" }
      end
    end

  end

  def submissions
    @ai_contest = AiContest.find(params[:id])
    permitted_to! :submit, @ai_contest
    @ai_submissions = AiSubmission.where(:user_id => current_user.id, :ai_contest_id => @ai_contest.id)
    respond_to do |format|
      format.html { render :layout => "ai_contest" }
    end
  end

  def scoreboard
    @ai_contest = AiContest.find(params[:id])
    @submissions = @ai_contest.submissions.active

    respond_to do |format|
      format.html { render :layout => "ai_contest" }
      #format.json { render json: @ai_contest }
    end
  end

  # GET /ai_contests/new
  # GET /ai_contests/new.json
  def new
    @ai_contest = AiContest.new
    @ai_contest.owner_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ai_contest }
    end
  end

  # GET /ai_contests/1/edit
  def edit
    @ai_contest = AiContest.find(params[:id])
  end

  # POST /ai_contests
  # POST /ai_contests.json
  def create
    respond_to do |format|
      if @ai_contest.update_attributes(permitted_params)
        format.html { redirect_to @ai_contest, notice: 'Ai contest was successfully created.' }
        format.json { render json: @ai_contest, status: :created, location: @ai_contest }
      else
        format.html { render action: "new" }
        format.json { render json: @ai_contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ai_contests/1
  # PATCH/PUT /ai_contests/1.json
  def update
    @ai_contest = AiContest.find(params[:id])

    respond_to do |format|
      if @ai_contest.update_attributes(ai_contest_params)
        format.html { redirect_to @ai_contest, notice: 'Ai contest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ai_contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ai_contests/1
  # DELETE /ai_contests/1.json
  def destroy
    @ai_contest = AiContest.find(params[:id])
    @ai_contest.destroy

    respond_to do |format|
      format.html { redirect_to ai_contests_url }
      format.json { head :no_content }
    end
  end

  def rejudge
    @ai_contest.rejudge
    redirect_to @ai_contest, :notice => "All contest games will be rejudged."
  end

  def judge
    @ai_contest.prod_judge
    redirect_to @ai_contest, :notice => "Judging has been prodded."
  end
  private

    def permitted_params
      @_permitted_params ||= begin
        permitted_attributes = [:title, :start_time, :end_time, :statement, :judge, :sample_ai, :iterations, :iterations_preview]
        permitted_attributes << :owner_id if permitted_to? :transfer, @contest
        params.require(:ai_contest).permit(*permitted_attributes)
      end
    end

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def ai_contest_params
      permitted_params
    end

    def submit_params # attributes allowed to be included in submissions
      @_submit_attributes ||= begin
        submit_attributes = [:language, :source_file]
        submit_attributes << [:source] if permitted_to? :submit_source, @problem
        submit_attributes
      end
      params.require(:ai_submission).permit(*@_submit_attributes).merge(:user_id => current_user.id, :ai_contest_id => params[:id],
        :name => params[:ai_submission][:source_file].original_filename.split('.')[0].humanize )
    end
end
