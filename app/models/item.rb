class Item < ApplicationRecord
  validates :image, :name, :minimum_bets, :online_at, :offline_at, :start_at, :status, presence: true
  enum status: [:active, :inactive]
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_bets, numericality: { greater_than: 0 }

  belongs_to :category
  has_many :bets
  has_many :winners

  mount_uploader :image, ImageUploader
  default_scope { where(deleted_at: nil) }

  def destroy
    if self.bets.present?
      errors.add(:base, "You cannot delete item once it has at least one bet")
      return false
    else
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
    betting_bets = bets.where(batch_count: batch_count).betting
    winning_bet = betting_bets.sample
    winning_bet.win!
    betting_bets.where.not(state: :won).each {|bet| bet.lose!}
    winner = Winner.new(item_batch_count: winning_bet.batch_count, user: winning_bet.user, item:winning_bet.item, bet: winning_bet)
    winner.save!
  end
end

