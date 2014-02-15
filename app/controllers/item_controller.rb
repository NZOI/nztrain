class ItemController < ApplicationController

  def show
    @item = Item.find(params[:id])
    authorize @item, :show?
  end

  def label
    @item = Item.find(params[:id])
    authorize @item, :show?
    render :label, :layout => false
  end
end
