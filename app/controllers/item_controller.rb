class ItemController < ApplicationController
  def show
    @item = Item.find(params[:id])
    authorize @item, :show?
  end

  def label
    @item = Item.find(params[:id])
    authorize @item, :show?
    render :label, layout: false
  end

  def loan
    @item = Item.find(params[:id])
    authorize @item, :manage?
    if @item.loan!(params[:item][:holder_id])
      redirect_to @item, notice: "Item Loaned"
    else
      redirect_to @item, alert: "No such user"
    end
  end

  def return
    @item = Item.find(params[:id])
    authorize @item, :manage?
    if @item.return!(params[:item][:holder_id])
      redirect_to @item, notice: "Item returned"
    else
      redirect_to @item, alert: "No such user"
    end
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
