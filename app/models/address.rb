class Address < ApplicationRecord
  LIMIT = 5
  validates :name, :street_address, :genre, presence: true
  validates :phone_number, phone: true
  validates_presence_of :is_default, {allow_blank: true}
  belongs_to :region
  belongs_to :province
  belongs_to :city
  belongs_to :barangay
  belongs_to :user
  enum genre: [:home, :office]
  before_commit :update_default
  before_destroy :validation_destroy
  before_create :default_first_record

  validate on: :create do |record|
    record.five_address_only
  end

  def five_address_only
    return unless user
    if user.addresses.reload.count >= LIMIT
      errors.add(:base, "Too Many Address")
    end
  end

  def default_first_record
    unless user.addresses.present?
      self.is_default = true
    end
  end

  def update_default
    if is_default
      user.addresses.where("id != ?", self.id).update_all(is_default: false)
    end
  end

  def validation_destroy
    if is_default
      errors.add(:base, "Default can't be destroyed")
      throw(:abort)
    end
  end
end
