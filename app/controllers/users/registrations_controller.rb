class Users::RegistrationsController < Devise::RegistrationsController

  def new
    @promoter = User.find_by_email(cookies[:promoter])&.id
    super
    unless cookies[:promoter]
      cookies[:promoter] = params[:promoter]
    end
  end

  def create
    params[:user][:parent_id] = User.find_by_email(cookies[:promoter])&.id
    super
  end

  def edit; end

  def update
    if params[:user][:current_password].present?
      if current_user.update_with_password(password_params)
        flash[:notice]= "Updated successfully!"
        sign_in @user, :bypass => true
        redirect_to edit_user_registration_path
      else
        flash[:alert] = 'Oh No! Something Went Wrong in password update field, Please Try Again.'
        render :edit
      end
    else
      if current_user.update(userinfo_params)
        flash[:notice]="Updated successfully!"
        redirect_to edit_user_registration_path
      else
        flash[:alert] = 'Oh No! Something Went Wrong, Please Try Again.'
        render :edit
      end
    end
  end

  private

  def userinfo_params
    params.require(:user).permit(:email, :username, :phone, :image)
  end

  def password_params
    params.require(:user).permit(:password,:password_confirmation, :current_password, :email, :username, :phone, :image)
  end

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :parent_id)
  end
end
