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

  def scan
    @item = Item.find(params[:id])
    if @item[:scan_token].nil?
      authorize @item, :show?
    else
      raise Pundit::NotAuthorizedError unless @item.scan_token == params[:scan_token]
    end

    render :show # will have different content later
  end
end
