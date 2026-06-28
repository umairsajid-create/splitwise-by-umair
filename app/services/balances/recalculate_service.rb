# frozen_string_literal: true

module Balances
  class RecalculateService
    def initialize(user)
      @user = user
    end

    # Recalculates the user's global balance_cents from scratch
    # Call this after any expense/settlement is created, updated, or deleted
    def call
      total = @user.expense_splits.sum("paid_amount_cents - owed_amount_cents")
      @user.update_column(:balance_cents, total)
    end
  end
end
