class Item < ApplicationRecord
  validates :image, :name, :minimum_bets, :online_at, :offline_at, :start_at, :status, presence: true
  enum status: [:active, :inactive]
  validates :quantity, numericality: { greater_than: 0 }
  validates :minimum_bets, numericality: { greater_than: 0 }

  belongs_to :category

  mount_uploader :image, ImageUploader
  default_scope { where(deleted_at: nil) }
  def destroy
    update(deleted_at: Time.current)
  end

  include AASM
  aasm column: :state do
    state :pending, initial: true
    state :starting, :paused, :ended, :cancelled

    event :start do
      transitions from: [:pending, :ended, :cancelled], to: :starting, after: :set_process, guards: [:greater_than_zero?, :offline_future?, :active?]
      transitions from: :paused, to: :starting
    end

    event :pause do
      transitions from: :starting, to: :paused
    end

    event :end do
      transitions from: :starting, to: :ended
    end

    event :cancel, after: :increment_quantity do
      transitions from: [:starting, :paused], to: :cancelled
    end
  end

  def set_process
    self.update(quantity: self.quantity - 1, batch_count: self.batch_count + 1)
  end

  def greater_than_zero?
    quantity > 0
  end

  def offline_future?
    offline_at > Time.now
  end

  def increment_quantity
    self.quantity+=1
  end
end
