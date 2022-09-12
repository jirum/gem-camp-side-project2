class LotteryController < ApplicationController
  before_action :authenticate_user!, only: :create
  before_action :set_item, only: :create

  def index
    @items = Item.active.starting
    if params[:category]
      @items = @items.includes(:category).where(category: { name: params[:category] })
    end
    @categories = Category.all
  end

  def show
    @item = Item.active.starting.find(params[:id])
    @bet = Bet.new
    @bets = @item.bets.where(user: current_user).where(batch_count: @item.batch_count)
  end

  def create
    if current_user.coins >= params[:bet][:coins].to_i
      begin
        loop_count = params[:bet][:coins].to_i
        params[:bet][:coins] = 1
        params[:bet][:item_id] = @item.id
        ActiveRecord::Base.transaction do
          loop_count.times do
            @bet = Bet.new(bet_params)
            @bet.user = current_user
            @bet.batch_count = @item.batch_count
            @bet.save!
          end
        end
        flash[:notice] = "successfully created"
      rescue ActiveRecord::RecordInvalid => exception
        flash[:alert] = exception
      end
      redirect_to lottery_path(@bet.item)
    else
      flash[:alert] = "You don't have enough coins"
      redirect_to lottery_path(@item)
    end
  end

  private

  def set_item
    @item = Item.find(params[:bet][:item_id])
  end

  def bet_params
    params.require(:bet).permit(:coins, :item_id)
  end
end