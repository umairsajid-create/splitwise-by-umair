
class ExpenseSplit < ApplicationRecord
  belongs_to :expense
  belongs_to :user
  validates :owed_amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :paid_amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :expense_id, message: "already has a split for this expense" }


  # Instance Methods
  def net_balance_cents
    paid_amount_cents - owed_amount_cents
  end

  def owed_amount
    owed_amount_cents / 100.0
  end

  def paid_amount
    paid_amount_cents / 100.0
  end

  def net_balance
    net_balance_cents / 100.0
  end
end
