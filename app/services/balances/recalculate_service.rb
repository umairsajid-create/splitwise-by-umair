# frozen_string_literal: true

module Balances
  class RecalculateService
    def initialize(user)
      @user = user
    end

    # Recalculates the user's global balance_cents from scratch.
    # IMPORTANT: We JOIN on expenses table and filter status = 0 (active)
    # so that soft-deleted expenses are fully excluded from balances.
    def call
      total = @user.expense_splits
                   .joins(:expense)
                   .where(expenses: { status: 0 })  # 0 = active
                   .sum("expense_splits.paid_amount_cents - expense_splits.owed_amount_cents")

      @user.update_column(:balance_cents, total)
    end
  end
end
