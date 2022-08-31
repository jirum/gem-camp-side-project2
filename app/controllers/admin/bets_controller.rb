class Admin::BetsController < AdminController
  before_action :set_bet, only: :cancel

  def index
    @bets = Bet.includes(:user, :item)
    @bets = @bets.where(serial_number: params[:serial_number]) if params[:serial_number].present?
    @bets = @bets.where(item: {name: params[:product_name]}) if params[:product_name].present?
    @bets = @bets.where(user: {email: params[:email]}) if params[:email].present?
    @bets = @bets.where(state: params[:state]) if params[:state].present?
    @bets = @bets.where(created_at: params[:start_date].to_datetime..params[:end_date].to_datetime) if params[:start_date].present? && params[:end_date].present?
  end

  def cancel
    if @bet.cancel!
      flash[:notice] = "Successfully Cancel"
    else
      flash[:alert] = @bet.errors.full_messages.join(', ')
    end
    redirect_to admin_bets_path
  end

  private

  def set_bet
    @bet = Bet.find(params[:bet_id])
  end
end