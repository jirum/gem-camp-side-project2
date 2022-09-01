class LotteryController < ApplicationController
  before_action :authenticate_user!, only: :create

  def index
    @items = Item.active.starting
    if params[:category]
      @items = @items.includes(:category).where(category: { name: params[:category] })
    end
    @categories = Category.all
  end

  def show
    if @item = Item.active.starting.find_by_id(params[:id])
      @bet = Bet.new
      @bets = @item.bets.where(user: current_user).where(batch_count: @item.batch_count)
    else
      not_found
    end
  end

  def create
    begin
      @item = Item.find(params[:bet][:item_id])
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
  end

  private

  def bet_params
    params.require(:bet).permit(:coins, :item_id, :batch_count)
  end
end