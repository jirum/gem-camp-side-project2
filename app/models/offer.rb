class Offer < ApplicationRecord
  validates :image, :name, :genre, :status, :amount, :coin, presence: true
  enum status: [:active, :inactive]
  enum genre:[:one_time, :monthly, :weekly, :daily, :regular]

  mount_uploader :image, ImageUploader
end
