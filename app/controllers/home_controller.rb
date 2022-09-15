class HomeController < ApplicationController
  before_action :authenticate_user!, except: :index

  def index
    @winners = Winner.published.limit(5).order(id: :desc)
    @items = Item.active.starting.limit(8)
  end
end
