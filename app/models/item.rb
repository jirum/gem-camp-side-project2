class Item < ApplicationRecord
  validates :image, :name, :minimum_bets, :online_at, :offline_at, :start_at, :status, presence: true
  enum status: [:active, :inactive]
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_bets, numericality: { greater_than: 0 }

  belongs_to :category
  has_many :bets

  mount_uploader :image, ImageUploader
  default_scope { where(deleted_at: nil) }

  def destroy
    unless self.bets.present?
      update(deleted_at: Time.current)
    end
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
      transitions from: [:starting, :paused], to: :ended, after: :pick_winner, guard: :reach_minimum_bets
    end

    event :cancel, after: [:increment_quantity, :bet_cancel] do
      transitions from: [:starting, :paused], to: :cancelled
    end
  end

  def set_process
    update(quantity: quantity - 1, batch_count: batch_count + 1)
  end

  def greater_than_zero?
    quantity > 0
  end

  def offline_future?
    offline_at > Time.now
  end

  def increment_quantity
    update(quantity: quantity + 1)
  end

  def bet_cancel
    bets.where(batch_count: batch_count).where.not(state: :cancelled).each { |bet| bet.cancel! }
  end

  def reach_minimum_bets
    bets.where(batch_count: batch_count).size >= minimum_bets
  end

  def pick_winner
    bets = bets.where(batch_count: batch_count).where.not(state: :cancelled)
    winner = bets.sample
    winner.win!
    item_bets.where.not(state: :won).update(state: :lost)
    won = Winner.new(item_batch_count: winner.batch_count, user: winner.user, item: winner.item, bet: winner, address: winner.user.addresses.find_by(is_default: true))
    won.save!
  end
end

