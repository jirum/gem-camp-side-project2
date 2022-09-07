class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!, only: :show

  def show
    @orders = Order.where(user: current_user) if params[:report] == 'order' || params[:report].blank?
    @bets = Bet.includes(:item).where(user: current_user) if params[:report] == 'bet'
    @invitations = User.where(parent: current_user) if params[:report] == 'invite'
    @winners = Winner.includes(:item, :bet).where(user: current_user) if params[:report] == 'winner'
  end
end