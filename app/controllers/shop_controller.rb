class ShopController < ApplicationController
  before_action :set_order, only: :new_order
  before_action :authenticate_user!, only: :new_order

  def index
    @offers = Offer.active
  end

  def new_order
    @order = Order.new
    @order.genre = :deposit
    @order.amount = @offer.amount
    @order.coin = @offer.coin
    @order.user = current_user
    @order.offer = @offer
    if @order.save
      if @order.may_submit? && @order.submit!
        flash[:notice] = "Order successfully"
        redirect_to shop_index_path
      else
        flash[:alert] = @order.errors.full_messages.join(', ')
        render :index
      end
    end
  end

  private

  def set_order
    @offer = Offer.active.find(params[:shop_id])
  end
end