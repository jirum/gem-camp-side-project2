class Admin::ItemsController < AdminController
  before_action :set_item, only: [:destroy, :edit, :update]

  def index
    @items = Item.includes(:category)
    @items = @items.where(name: params[:name]) if params[:name].present?
  end

  def new
    @item= Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      flash[:notice] = "Successfully Created"
      redirect_to admin_items_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @item.update(item_params)
      flash[:notice] = "Successfully Updated"
      redirect_to admin_items_path
    else
      render :edit
    end
  end

  def destroy
    if @item.destroy
      flash[:notice] = "Successfully Deleted"
    else
      flash[:alert] = "You cannot delete item once it has at least one bet"
    end
    redirect_to admin_items_path
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:image, :name, :quantity, :minimum_bets, :state, :batch_count, :online_at, :offline_at, :start_at, :status, :category_id)
  end
end
