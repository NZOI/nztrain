class ProblemSetsController < ApplicationController
  #load_and_authorize_resource :except => :create
  #skip_authorize_resource :only => [:add_problem, :remove_problem]
  filter_resource_access :collection => {:index => :browse}, :additional_member => {:remove_problem => :update}

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:title]
      permitted_attributes << :owner_id if permitted_to? :transfer, @problem_set
      params.require(:problem_set).permit(*permitted_attributes)
    end
  end

  def new_problem_set_from_params
    @problem_set = ProblemSet.new(:owner => current_user)
  end

  def add_problem # currently unused function
    @problem_set = ProblemSet.find(params[:problem][:problem_set_ids])
    permitted_to! :update, @problem_set
    problem = Problem.find(params[:problem_id])
    permitted_to! :use, problem
    if @problem_set.problems.exists?(problem)
      redirect_to(problem, :alert => "This problem set already contains this problem")
      return
    end
    @problem_set.problems.push(problem)
    redirect_to(problem, :notice => "Problem added.")
  end

  def remove_problem
    problem = Problem.find(params[:problem_id])
    @problem_set.problems.delete(problem)
    redirect_to(@problem_set, :notice => "Problem removed.")
  end

  # GET /problem_sets
  # GET /problem_sets.xml
  def index
    case params[:filter].to_s
    when 'my'
      permitted_to! :manage, ProblemSet.new(:owner_id => current_user.id)
      @problem_sets = ProblemSet.where(:owner_id => current_user.id)
    else
      permitted_to! :manage, ProblemSet.new
      @problem_sets = ProblemSet.scoped
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @problem_sets }
    end
  end

  # GET /problem_sets/1
  # GET /problem_sets/1.xml
  def show
    @groups = Group.all
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @problem_set }
    end
  end

  # GET /problem_sets/new
  # GET /problem_sets/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @problem_set }
    end
  end

  # GET /problem_sets/1/edit
  def edit
  end

  # POST /problem_sets
  # POST /problem_sets.xml
  def create
    respond_to do |format|
      if @problem_set.update_attributes(permitted_params)
        format.html { redirect_to(@problem_set, :notice => 'Problem set was successfully created.') }
        format.xml  { render :xml => @problem_set, :status => :created, :location => @problem_set }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @problem_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /problem_sets/1
  # PUT /problem_sets/1.xml
  def update
    respond_to do |format|
      if @problem_set.update_attributes(permitted_params)
        format.html { redirect_to(@problem_set, :notice => 'Problem set was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @problem_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /problem_sets/1
  # DELETE /problem_sets/1.xml
  def destroy
    @problem_set.destroy

    respond_to do |format|
      format.html { redirect_to(problem_sets_url) }
      format.xml  { head :ok }
    end
  end

end
