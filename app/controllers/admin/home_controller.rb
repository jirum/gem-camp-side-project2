class Admin::HomeController < AdminController

  def index
    @users = User.where(role: :client)
  end
end