class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :serial_number
      t.string :state
      t.decimal :amount
      t.integer :coin
      t.string :remarks
      t.integer :genre
      t.belongs_to :user
      t.belongs_to :offer
      t.timestamps
    end
  end
end
