class EvaluatorsController < ApplicationController
  before_filter :check_signed_in
  load_and_authorize_resource

  # GET /evaluators
  # GET /evaluators.xml
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @evaluators }
    end
  end

  # GET /evaluators/1
  # GET /evaluators/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @evaluator }
    end
  end

  # GET /evaluators/new
  # GET /evaluators/new.xml
  def new
    @evaluator.user_id = current_user.id
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @evaluator }
    end
  end

  # GET /evaluators/1/edit
  def edit
  end

  # POST /evaluators
  # POST /evaluators.xml
  def create
    @evaluator.accessible = [:user_id] # free to give others an evaluator to own
    @evaluator.attributes = params[:evaluator]

    respond_to do |format|
      if @evaluator.save
        format.html { redirect_to(@evaluator, :notice => 'Evaluator was successfully created.') }
        format.xml  { render :xml => @evaluator, :status => :created, :location => @evaluator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @evaluator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /evaluators/1
  # PUT /evaluators/1.xml
  def update
    @evaluator.accessible = [:user_id] if can? :manage, @evaluator

    respond_to do |format|
      if @evaluator.update_attributes(params[:evaluator])
        format.html { redirect_to(@evaluator, :notice => 'Evaluator was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @evaluator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluators/1
  # DELETE /evaluators/1.xml
  def destroy
    @evaluator.destroy

    respond_to do |format|
      format.html { redirect_to(evaluators_url) }
      format.xml  { head :ok }
    end
  end
end
