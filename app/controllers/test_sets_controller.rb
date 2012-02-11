class TestSetsController < ApplicationController
  # GET /test_sets
  # GET /test_sets.json
  def index
    @test_sets = TestSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @test_sets }
    end
  end

  # GET /test_sets/1
  # GET /test_sets/1.json
  def show
    @test_set = TestSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @test_set }
    end
  end

  # GET /test_sets/new
  # GET /test_sets/new.json
  def new
    @test_set = TestSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @test_set }
    end
  end

  # GET /test_sets/1/edit
  def edit
    @test_set = TestSet.find(params[:id])
  end

  # POST /test_sets
  # POST /test_sets.json
  def create
    @test_set = TestSet.new(params[:test_set])

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

    respond_to do |format|
      if @test_set.update_attributes(params[:test_set])
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
    @test_set.destroy

    respond_to do |format|
      format.html { redirect_to test_sets_url }
      format.json { head :ok }
    end
  end
end
