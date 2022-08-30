class Admin::WinnersController < AdminController
  before_action :set_winner, only: [:submit, :pay, :ship, :deliver, :publish, :remove_publish]

  def index
    @winners = Winner.includes(:user, :item, :bet, :address)
    @winners = @winners.where(bet: { serial_number: params[:serial_number] }) if params[:serial_number].present?
    @winners = @winners.where(user: { email: params[:email] }) if params[:email].present?
    @winners = @winners.where(item: { name: params[:product_name] }) if params[:product_name].present?
    @winners = @winners.where(state: params[:state]) if params[:state].present?
    @winners = @winners.where(created_at: params[:start_date].to_datetime..params[:end_date].to_datetime) if params[:start_date].present? && params[:end_date].present?
  end

  def submit
    if @winner.submit!
      redirect_to admin_winners_path
    end
  end

  def pay
    if @winner.pay!
      redirect_to admin_winners_path
    end
  end

  def ship
    if @winner.ship!
      redirect_to admin_winners_path
    end
  end

  def deliver
    if @winner.deliver!
      redirect_to admin_winners_path
    end
  end

  def publish
    if @winner.publish!
      redirect_to admin_winners_path
    end
  end

  def remove_publish
    if @winner.remove_publish!
      redirect_to admin_winners_path
    end
  end

  private

  def set_winner
    @winner = Winner.find(params[:winner_id])
  end
end

