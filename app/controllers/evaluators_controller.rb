class EvaluatorsController < ApplicationController
  load_and_authorize_resource :except => [:create]

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name, :description, :source]
      permitted_attributes << :owner_id if can? :transfer, @owner
      params.require(:evaluator).permit(*permitted_attributes)
    end
  end

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
    @evaluator.owner_id = current_user.id
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
    @evaluator = Evaluator.new(:owner_id => current_user.id)
    authorize! :create, @evaluator

    respond_to do |format|
      if @evaluator.update_attributes(permitted_params)
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
    respond_to do |format|
      if @evaluator.update_attributes(permitted_params)
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
