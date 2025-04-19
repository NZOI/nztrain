class OrganisationsController < ApplicationController
  def index
    authorize Organisation.new, :index?
    @organisations = Organisation.all
  end

  def show
    @organisation = Organisation.find(params[:id])
    authorize @organisation, :show?
  end

  def product
    @organisation = Organisation.find(params[:id])
    authorize @organisation, :show?
    @product = Product.find(params[:product_id])
    @items = Item.where(organisation_id: params[:id], product_id: params[:product_id])
  end

  def new_product_item
    @organisation = Organisation.find(params[:id])
    @product = Product.find(params[:product_id])
    @item = Item.new(organisation_id: params[:id], product_id: params[:product_id])
    authorize @item, :new?
  end

  def create_product_item
    @item = Item.new item_params.merge(organisation_id: params[:id], product_id: params[:product_id])
    authorize @item, :create?
    if @item.save
      redirect_to @item, notice: "Item created"
    else
      render action: "new_product_item"
    end
  end

  def edit
    @organisation = Organisation.find(params[:id])
    authorize @organisation, :edit?
  end

  def update
    @organisation = Organisation.find(params[:id])
    authorize @organisation, :update?
    if @organisation.update_attributes(organisation_params)
      redirect_to @organisation, notice: "Organisation updated"
    else
      render action: "edit"
    end
  end

  def new
    @organisation = Organisation.new
    authorize @organisation, :new?
  end

  def create
    @organisation = Organisation.new(organisation_params)
    authorize @organisation, :create?
    if @organisation.save
      redirect_to @organisation, notice: "Organisation created"
    else
      render action: "new"
    end
  end

  def destroy
    @organisation = Organisation.find(params[:id])
    authorize @organisation, :destroy?
    @organisation.destroy
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name)
  end

  def item_params
    params.require(:item).permit(:owner_id, :sponsor_id, :donator_id, :condition)
  end
end
