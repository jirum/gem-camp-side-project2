class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: :update
  before_action :sign_up_params, only: :create

  def new
    @promoter = User.find_by_email(cookies[:promoter])&.id
    super
    unless cookies[:promoter]
      cookies[:promoter] = params[:promoter]
    end
  end

  def create
    build_resource(sign_up_params)
    resource.parent_id = User.find_by_email(cookies[:promoter])&.id
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def edit; end

  def update
    if params[:user][:current_password].present?
      if current_user.update_with_password(password_params)
        flash[:alert]="Updated successfully!"
        sign_in @user, :bypass => true
        redirect_to edit_user_registration_path
      else
        flash[:error] = 'Oh No! Something Went Wrong in password update field, Please Try Again.'
        render :edit
      end
    else
      if current_user.update(userinfo_params)
        flash[:alert]="Updated successfully!"
        redirect_to edit_user_registration_path
      else
        flash[:error] = 'Oh No! Something Went Wrong, Please Try Again.'
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

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:phone, :username, :image])
  end

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
