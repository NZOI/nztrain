class TestSetsController < ApplicationController

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name, :problem_id, :points]
      params.require(:test_set).permit(*permitted_attributes)
    end
  end

  # GET /test_sets
  # GET /test_sets.json
  def index
    permitted_to! :inspect, Problem.find(params[:problem_id])
    @test_sets = TestSet.where(:problem_id => params[:problem_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @test_sets }
    end
  end

  # GET /test_sets/1
  # GET /test_sets/1.json
  def show
    @test_set = TestSet.find(params[:id])
    permitted_to! :inspect, @test_set.problem
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @test_set }
    end
  end

  # GET /test_sets/new
  # GET /test_sets/new.json
  def new
    raise Authorization::AuthorizationError
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @test_set }
    end
  end

  # GET /test_sets/1/edit
  def edit
  end

  # POST /test_sets
  # POST /test_sets.json
  def create
    raise Authorization::AuthorizationError
    @test_set = TestSet.new(permitted_params)
    permitted_to! :create, @test_set

    respond_to do |format|
      if @test_set.save
        format.html { redirect_to @test_set, :notice => 'Test set was successfully created.' }
        format.json { render :json => @test_set, :status => :created, :location => @test_set }
      else
        format.html { render :action => "new" }
        format.json { render :json => @test_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /test_sets/1
  # PUT /test_sets/1.json
  def update
    @test_set = TestSet.find(params[:id])
    permitted_to! :update, @test_set.problem
    respond_to do |format|
      if @test_set.update_attributes(permitted_params)
        format.html { redirect_to @test_set, :notice => 'Test set was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @test_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /test_sets/1
  # DELETE /test_sets/1.json
  def destroy
    @test_set = TestSet.find(params[:id])
    permitted_to! :destroy, @test_set
    @test_set.destroy

    respond_to do |format|
      format.html { redirect_to test_sets_url }
      format.json { head :ok }
    end
  end
end
