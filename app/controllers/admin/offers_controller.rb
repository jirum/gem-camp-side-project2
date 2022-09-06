class Admin::OffersController < AdminController
  before_action :set_offer, only: [:update, :edit, :destroy]

  def index
    @offers = Offer.all
    @offers = @offers.where(status: params[:status]) if params[:status].present?
    @offers = @offers.where(genre: params[:genre]) if params[:genre].present?
  end

  def new
    @offer = Offer.new
  end

  def create
    @offer = Offer.new(offer_params)
    if @offer.save
      flash[:notice] = "Successfully Created"
      redirect_to admin_offers_path
    else
      render :new
    end
  end

  def destroy
    if @offer.destroy
      flash[:notice] = "Successfully Deleted"
    else
      flash[:alert] = @offer.errors.full_messages.join(', ')
    end
    redirect_to admin_offers_path
  end

  def edit; end

  def update
    if @offer.update(offer_params)
      flash[:notice] = "Successfully Updated"
      redirect_to admin_offers_path
    else
      render :edit
    end
  end

  private

  def set_offer
    @offer = Offer.find(params[:id])
  end

  def offer_params
    params.require(:offer).permit(:image, :name, :genre, :status, :amount, :coin)
  end
end