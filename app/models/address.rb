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

  before_create :default_first_record

  validate on: :create do |record|
    record.five_address_only
  end

  def five_address_only
    return unless self.user
    if self.user.addresses.reload.count >= 5
      errors.add(:base, "Too Many Address")
    end
  end

  def default_first_record
    unless self.user.addresses.present?
      self.is_default = true
    end
  end

  def update_default
    if is_default
      self.user.addresses.where("id != ?", self.id).update_all(is_default: false)
    end
  end
end
