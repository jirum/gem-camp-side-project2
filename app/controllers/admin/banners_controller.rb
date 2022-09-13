class Admin::BannersController < AdminController
  before_action :set_banner, only: [:edit, :update, :destroy]

  def index
    @banners = Banner.all
    @banners = @banners.where(online_at: params[:start_date].to_datetime..params[:end_date].to_datetime) if params[:start_date].present? && params[:end_date].present?
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      flash[:notice] = "Successfully Created"
      redirect_to admin_banners_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @banner.update(banner_params)
      flash[:notice] = "Successfully Updated"
      redirect_to admin_banners_path
    else
      render :edit
    end
  end

  def destroy
    if @banner.destroy
      flash[:notice] = "Successfully Deleted"
    else
      flash[:alert] = @banner.errors.full_messages.join(', ')
    end
    redirect_to admin_banners_path
  end

  private

  def set_banner
    @banner = Banner.find(params[:id])
  end

  def banner_params
    params.require(:banner).permit(:preview, :status, :online_at, :offline_at)
  end
end
