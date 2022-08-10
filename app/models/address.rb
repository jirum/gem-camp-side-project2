class Address < ApplicationRecord
  validates_presence_of :name
  validates :phone_number, phone: true
  validates_presence_of :street_address
  validates_presence_of :genre
  validates_presence_of :is_default, {allow_blank: true}
  belongs_to :region
  belongs_to :province
  belongs_to :city
  belongs_to :barangay
  belongs_to :user
  enum genre: [:Home, :Office]
  before_commit :update_default


  def update_default
    if is_default
      self.user.addresses.where("id != ?", self.id).update_all(is_default: false)
    end
  end
end
