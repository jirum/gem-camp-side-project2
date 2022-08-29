class Admin::CategoriesController < AdminController
  before_action :set_category, only: [:destroy, :edit, :update]

  def index
    @categories = Category.all
    @categories = @categories.where(name: params[:name]) if params[:name].present?
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:notice] = "Successfully Created"
      redirect_to admin_categories_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      flash[:notice] = "Successfully Updated"
      redirect_to admin_categories_path
    else
      render :edit
    end
  end

  def destroy
    if @category.destroy
      flash[:notice] = "Successfully Deleted"
      redirect_to admin_categories_path
    else
      flash[:alert] = "You cannot delete category once it has at least one item"
      redirect_to admin_categories_path
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end