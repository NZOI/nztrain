class ProductsController < ApplicationController

  def index
    authorize Product.new, :index?
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
    authorize @product, :show?
  end

  def edit
    @product = Product.find(params[:id])
    authorize @product, :edit?
  end

  def update
    @product = Product.find(params[:id])
    authorize @product, :update?
    if @product.update_attributes(product_params)
      redirect_to @product, :notice => "Product updated"
    else
      render :action => "edit"
    end
  end

  def new
    @product = Product.new
    authorize @product, :new?
  end

  def create
    @product = Product.new(product_params)
    authorize @product, :create?
    if @product.save
      redirect_to @product, :notice => "Product created"
    else
      render :action => "new"
    end
  end

  def destroy
    @product = Product.find(params[:id])
    authorize @product, :destroy?
    @product.destroy
  end

  private
  def product_params
    params.require(:product).permit(:name, :gtin)
  end
end
