class Order < ApplicationRecord
  validates :remarks, presence: true, if: :specific_genre
  validates :amount, :coin, numericality: { greater_than: 0 }, if: :deposit?
  validates :amount, numericality: { greater_than_or_equal: 0 }, unless: :deposit?
  enum genre: [:deposit, :increase, :deduct, :bonus, :share]

  belongs_to :user
  belongs_to :offer, optional: true

  after_create :generate_serial_number

  include AASM
  aasm column: :state do
    state :pending, initial: true
    state :submitted, :cancelled, :paid

    event :submit do
      transitions from: :pending, to: :submitted
    end

    event :pay, after: :update_coins_if_to_pay do
      transitions from: :submitted, to: :paid, guard: :deposit?, after: :update_deposit_if_to_pay
      transitions from: :pending, to: :paid, guard: :check_coin_if_to_pay
    end

    event :cancel do
      transitions from: [:pending, :submitted], to: :cancelled
      transitions from: :paid, to: :cancelled, guard: :check_coin_if_to_cancel, after: [:update_coins_if_to_cancel, :update_deposit_if_to_cancel]
    end
  end

  def update_coins_if_to_pay
    if !deduct?
      user.update(coins: user.coins + coin)
    else
      user.update(coins: user.coins - coin)
    end
  end

  def update_deposit_if_to_pay
    if deposit?
      user.update(total_deposit: user.total_deposit + amount)
    end
  end

  def update_coins_if_to_cancel
    if !deduct?
      user.update(coins: user.coins - coin)
    else
      user.update(coins: user.coins + coin)
    end
  end

  def update_deposit_if_to_cancel
    if deposit?
      user.update(total_deposit: user.total_deposit - amount)
    end
  end

  def check_coin_if_to_cancel
    return true if deduct?
    if (user.coins >= coin)
      true
    else
      errors.add(:base, "Don't have enough coins")
      false
    end
  end

  def check_coin_if_to_pay
    return true unless deduct?
    if (user.coins >= coin)
      true
    else
      errors.add(:base, "Don't have enough coins")
      false
    end
  end

  def specific_genre
    increase? || deduct? || bonus?
  end

  def generate_serial_number
    ActiveRecord::Base.connection.execute("UPDATE `orders` SET `orders`.`serial_number` = CONCAT(DATE_FORMAT(CONVERT_TZ(orders.created_at, '+00:00', '+8:00'), '%y%m%d'),'-',#{id},'-',#{user.id},'-',
                                                    (SELECT LPAD(count(*), 4, 0)
                                                     FROM `orders` where `orders`.`user_id` = #{user.id}))
                                                     WHERE orders.id = #{id}")
  end
end