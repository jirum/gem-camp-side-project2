class Admin::CategoriesController < AdminController
  before_action :authenticate_admin_user!
  before_action :set_category, only: [:destroy, :edit, :update]

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path
  end

  private

  def set_category
    @category = Category.find_by_id(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end