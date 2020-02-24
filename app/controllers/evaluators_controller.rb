class EvaluatorsController < ApplicationController

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name, :description, :source]
      permitted_attributes << :owner_id if policy(@evaluator || Evaluator).transfer?
      params.require(:evaluator).permit(*permitted_attributes)
    end
  end

  # GET /evaluators
  # GET /evaluators.xml
  def index
    authorize Evaluator, :index?
    @evaluators = Evaluator.all.order(id: :asc)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @evaluators }
    end
  end

  # GET /evaluators/1
  # GET /evaluators/1.xml
  def show
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :show?
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @evaluator }
    end
  end

  # GET /evaluators/new
  # GET /evaluators/new.xml
  def new
    @evaluator = Evaluator.new(:owner_id => current_user.id)
    authorize @evaluator, :new?
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @evaluator }
    end
  end

  # GET /evaluators/1/edit
  def edit
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :edit?
  end

  # POST /evaluators
  # POST /evaluators.xml
  def create
    @evaluator = Evaluator.new(permitted_params)
    @evaluator.owner_id ||= current_user.id
    authorize @evaluator, :create?
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
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :update?
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
    @evaluator = Evaluator.find(params[:id])
    authorize @evaluator, :destroy?
    @evaluator.destroy

    respond_to do |format|
      format.html { redirect_to(evaluators_url) }
      format.xml  { head :ok }
    end
  end
end
