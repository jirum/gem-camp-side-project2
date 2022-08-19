class Users::SessionsController < Devise::SessionsController

  def new
    super
  end

  def create
    user = User.find_for_authentication(email: params[:user][:email])
    if user&.admin? && user&.valid_password?(params[:user][:password])
      flash[:notice] = "You do not have permission"
      redirect_to action: :new
    else
      super
    end
  end
end
