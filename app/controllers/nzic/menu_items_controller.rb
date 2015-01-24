class NZIC::MenuItemsController < ApplicationController

  def permitted_params
    params.require(:nzic_menu_item).permit(:name, :link)
  end

  def index
    authorize NZIC::MenuItem, :index?
    @menu_items = policy_scope(NZIC::MenuItem).order(:id)
  end

  def show
    @menu_item = NZIC::MenuItem.find(params[:id])
    authorize @menu_item, :show?
  end

  def new
    @menu_item = NZIC::MenuItem.new
    authorize @menu_item, :new?
  end

  def create
    @menu_item = NZIC::MenuItem.new(permitted_params)
    authorize @menu_item, :create?

    respond_to do |format|
      if @menu_item.save
        format.html { redirect_to @menu_item, notice: "Menu item created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @menu_item = NZIC::MenuItem.find(params[:id])
    authorize @menu_item, :edit?
  end

  def update
    @menu_item = NZIC::MenuItem.find(params[:id])
    authorize @menu_item, :update?

    respond_to do |format|
      if @menu_item.update_attributes(permitted_params)
        format.html { redirect_to @menu_item, notice: "Menu item updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @menu_item = NZIC::MenuItem.find(params[:id])
    authorize @menu_item, :destroy?
    @menu_item.destroy

    respond_to do |format|
      format.html { redirect_to nzic_menu_item_path, notice: "Menu item destroyed." }
    end
  end
end
