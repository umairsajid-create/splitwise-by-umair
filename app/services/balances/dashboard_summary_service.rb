# frozen_string_literal: true

module Balances
  class DashboardSummaryService
    def initialize(user)
      @user = user
    end

    # Returns gross owe/owed totals across all groups (Splitwise-style).
    # Net total matches user.balance_cents.
    def call
      you_are_owed_cents = 0
      you_owe_cents      = 0

      balances_by_group.each_value do |balance|
        if balance.positive?
          you_are_owed_cents += balance
        elsif balance.negative?
          you_owe_cents += balance.abs
        end
      end

      {
        total_balance_cents: @user.balance_cents,
        you_are_owed_cents:  you_are_owed_cents,
        you_owe_cents:       you_owe_cents
      }
    end

    private

    def balances_by_group
      @user.expense_splits
           .joins(:expense)
           .where(expenses: { status: 0, group_id: @user.group_ids })
           .group("expenses.group_id")
           .sum("expense_splits.paid_amount_cents - expense_splits.owed_amount_cents")
    end
  end
end
