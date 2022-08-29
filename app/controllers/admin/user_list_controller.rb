class Admin::UserListController < AdminController
  def index
    @users = User.where(role: :client)
    @users = @users.where(email: params[:email]) if params[:email].present?
  end
end