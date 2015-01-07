class ItemsController < ApplicationController

  def index
    authorize Item.new, :index?
    @items = Item.all
  end

  #def new
  #  @product = Item.new
  #  authorize @product, :new?
  #end

  #def create
  #  @product = Item.new(product_params)
  #  authorize @product, :create?
  #  if @product.save
  #    redirect_to @product, :notice => "Item created"
  #  else
  #    render :action => "new"
  #  end
  #end

  private
  #def product_params
  #  params.require(:product).permit(:name, :gtin)
  #end
end
