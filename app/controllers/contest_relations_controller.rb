class ContestRelationsController < ApplicationController
  filter_resource_access

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:user_id, :contest_id, :started_at]
      params.require(:contest_relation).permit(*permitted_attributes)
    end
  end

  # GET /contest_relations
  # GET /contest_relations.xml
  def index
    @contest_relations = ContestRelation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contest_relations }
    end
  end

  # GET /contest_relations/1
  # GET /contest_relations/1.xml
  def show
    @contest_relation = ContestRelation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest_relation }
    end
  end

  # GET /contest_relations/new
  # GET /contest_relations/new.xml
  def new
    @contest = Contest.new
    @start_time = ""
    @end_time = ""

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contest_relations/1/edit
  def edit
    @contest_relation = ContestRelation.find(params[:id])
  end

  # POST /contest_relations
  # POST /contest_relations.xml
  def create
    @contest_relation = ContestRelation.new(permitted_params)
    authorize @contest_relation, :create?

    respond_to do |format|
      if @contest_relation.save
        format.html { redirect_to(@contest_relation, :notice => 'Contest relation was successfully created.') }
        format.xml  { render :xml => @contest_relation, :status => :created, :location => @contest_relation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contest_relation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contest_relations/1
  # PUT /contest_relations/1.xml
  def update
    respond_to do |format|
      if @contest_relation.update_attributes(permitted_params)
        format.html { redirect_to(@contest_relation, :notice => 'Contest relation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contest_relation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contest_relations/1
  # DELETE /contest_relations/1.xml
  def destroy
    @contest_relation = ContestRelation.find(params[:id])
    @contest_relation.destroy

    respond_to do |format|
      format.html { redirect_to(contest_relations_url) }
      format.xml  { head :ok }
    end
  end
end
