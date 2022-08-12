class Admin::ItemsController < AdminController
  before_action :authenticate_admin_user!
  before_action :set_item, only: [:destroy, :edit, :update]

  def index
    @items = Item.all
  end

  def show
  end

  def new
    @item= Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to admin_items_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @item.update(item_params)
      redirect_to admin_items_path
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    redirect_to admin_items_path
  end

  private

  def set_item
    @item = Item.find_by_id(params[:id])
  end

  def item_params
    params.require(:item).permit(:image, :name, :quantity, :minimum_bets, :state, :batch_count, :online_at, :offline_at, :start_at, :status)
  end
end
