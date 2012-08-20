class TestCasesController < ApplicationController
  load_and_authorize_resource :except => [:create]

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:input, :output, :name]
      params.require(:test_case).permit(*permitted_attributes)
    end
  end

  # GET /test_cases
  # GET /test_cases.xml
  def index
    if params[:problem_id]
      logger.debug "problem is " + params[:problem_id]
      @test_cases = Problem.find(params[:problem_id]).test_cases.accessible_by(current_ability).distinct
    else
      @test_cases = @test_cases.distinct
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @test_cases }
    end
  end

  # GET /test_cases/1
  # GET /test_cases/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @test_case }
    end
  end

  # GET /test_cases/new
  # GET /test_cases/new.xml
  def new
    #authorize! :update, Problem.find(params[:problem_id])
    @defaultProblem = params[:problem_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @test_case }
    end
  end

  # GET /test_cases/1/edit
  def edit
    authorize! :update, Problem.find(@test_case.test_set.problem_id)
  end

  # POST /test_cases
  # POST /test_cases.xml
  def create
    @test_case = TestCase.new(permitted_params)
    authorize! :update, Problem.find(params[:test_case][:problem_id])

    respond_to do |format|
      if @test_case.save
        format.html { redirect_to(@test_case, :notice => 'Test case was successfully created.') }
        format.xml  { render :xml => @test_case, :status => :created, :location => @test_case }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @test_case.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /test_cases/1
  # PUT /test_cases/1.xml
  def update
    authorize! :update, Problem.find(@test_case.test_set.problem_id)
    authorize! :update, TestSet.find(params[:test_case][:test_set_id]).problem

    respond_to do |format|
      if @test_case.update_attributes(permitted_params)
        format.html { redirect_to(@test_case, :notice => 'Test case was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @test_case.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /test_cases/1
  # DELETE /test_cases/1.xml
  def destroy
    @test_case.destroy

    respond_to do |format|
      format.html { redirect_to(test_cases_url) }
      format.xml  { head :ok }
    end
  end
end
