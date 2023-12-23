class ProblemSetsController < ApplicationController

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name, :problem_associations_attributes => [ :id, :problem_set_order_position, :weighting ]]
      permitted_attributes << :owner_id if policy(@problem_set || ProblemSet).transfer?
      params.require(:problem_set).permit(*permitted_attributes)
    end
  end

  def add_problem # unused
    @problem_set = ProblemSet.find(params[:problem][:problem_set_ids])
    authorize @problem_set, :update?
    problem = Problem.find(params[:id]) # note switched params - TODO: fix form
    authorize problem, :use?
    if @problem_set.problems.exists?(problem.id)
      redirect_to(problem, :alert => "This problem set already contains this problem")
      return
    end
    @problem_set.problems.push(problem)
    redirect_to(problem, :notice => "Problem added.")
  end

  def remove_problem
    @problem_set = ProblemSet.find(params[:id])
    problem = Problem.find(params[:problem_id])
    @problem_set.problems.delete(problem)
    redirect_to(@problem_set, :notice => "Problem removed.")
  end

  # GET /problem_sets
  # GET /problem_sets.xml
  def index
    case params[:filter].to_s
    when 'my'
      authorize ProblemSet.new(:owner_id => current_user.id), :manage?
      @problem_sets = ProblemSet.where(:owner_id => current_user.id)
    else
      authorize ProblemSet.new, :manage?
      @problem_sets = ProblemSet.all
    end
    @problem_sets = @problem_sets.order(name: :asc).page(params[:page]).per_page(25)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @problem_sets }
    end
  end

  # GET /problem_sets/1
  # GET /problem_sets/1.xml
  def show
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :show?
    if user_signed_in?
      if policy(Group.new).update?
        @groups = Group.all
      else
        @groups = Group.where(:owner_id => current_user.id)
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @problem_set }
    end
  end

  # GET /problem_sets/new
  # GET /problem_sets/new.xml
  def new
    @problem_set = ProblemSet.new(:owner => current_user)
    authorize @problem_set, :new?
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @problem_set }
    end
  end

  # GET /problem_sets/1/edit
  def edit
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :edit?
  end

  # POST /problem_sets
  # POST /problem_sets.xml
  def create
    @problem_set = ProblemSet.new(permitted_params)
    @problem_set.owner ||= current_user
    authorize @problem_set, :create?
    respond_to do |format|
      if @problem_set.save
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
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :update?

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
    @problem_set = ProblemSet.find(params[:id])
    authorize @problem_set, :destroy?
    @problem_set.destroy

    respond_to do |format|
      format.html { redirect_to(problem_sets_url) }
      format.xml  { head :ok }
    end
  end

end
