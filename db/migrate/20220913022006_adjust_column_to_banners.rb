class AdjustColumnToBanners < ActiveRecord::Migration[6.1]
  def change
    add_column :banners, :deleted_at, :datetime
  end
end
