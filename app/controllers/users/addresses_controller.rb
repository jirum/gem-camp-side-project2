class Users::AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_own_address, only: [:destroy, :edit, :update]

  def index; end

  def new
    @address= Address.new
  end

  def create
    @address = Address.new(address_params)
    @address.user = current_user

    if @address.save
      redirect_to users_addresses_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @address.update(address_params)
      redirect_to users_addresses_path
    else
      render :edit
    end
  end

  def destroy
    if @address.is_default?
      flash[:alert] = "Action failed"
      redirect_to users_addresses_path
    else
      @address.destroy
      redirect_to users_addresses_path
    end
  end

  private

  def set_own_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:name, :phone_number, :street_address, :genre, :region_id, :province_id, :city_id, :barangay_id, :remark, :is_default)
  end
end
