class TestCasesController < ApplicationController
  # filter_resource_access :collection => []

  def permitted_params
    permitted_attributes = [:input, :output, :name]
    params.require(:test_case).permit(*permitted_attributes)
  end

  # GET /test_cases
  # GET /test_cases.xml
  def index
    @problem = Problem.find(params[:problem_id])
    if params[:problem_id]
      permitted_to! :inspect, @problem
      logger.debug "problem is " + params[:problem_id]
      @test_cases = @problem.test_cases
    else
      raise Pundit::NotAuthorizedError
      @test_cases = @test_cases.distinct
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @test_cases }
    end
  end

  # GET /test_cases/1
  # GET /test_cases/1.xml
  def show
    @test_case = TestCase.find(params[:id])
    permitted_to! :inspect, @test_case.problems.first
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render xml: @test_case }
    end
  end

  # GET /test_cases/1/edit
  def edit
    @test_case = TestCase.find(params[:id])
    @test_case.problems.each do |problem|
      permitted_to! :update, problem
    end
  end

  # PUT /test_cases/1
  # PUT /test_cases/1.xml
  def update
    @test_case = TestCase.find(params[:id])
    @test_case.problems.each do |problem|
      permitted_to! :update, problem
    end

    respond_to do |format|
      if @test_case.update_attributes(permitted_params)
        format.html { redirect_to(@test_case, notice: "Test case was successfully updated.") }
        format.xml { head :ok }
      else
        format.html { render action: "edit" }
        format.xml { render xml: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_cases/1
  # DELETE /test_cases/1.xml
  def destroy
    @test_case = TestCase.find(params[:id])
    @test_case.problems.each do |problem|
      permitted_to! :update, problem
    end
    @test_case.destroy

    respond_to do |format|
      format.html { redirect_to(test_cases_url) }
      format.xml { head :ok }
    end
  end
end
