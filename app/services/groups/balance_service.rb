# frozen_string_literal: true

module Groups
  class BalanceService
    def initialize(group)
      @group = group
    end

    # Returns array desc sorted by balance
    def call
      @group.group_members.includes(:user).map do |member|
        {
          user:          member.user,
          balance_cents: calculate_member_balance(member.user)
        }
      end.sort_by { |entry| entry[:balance_cents] }.reverse
    end

    private

    def calculate_member_balance(user)
      # status = 0 mean active
      @group.expenses
            .where(status: 0)
            .joins(:expense_splits)
            .where(expense_splits: { user_id: user.id })
            .sum("expense_splits.paid_amount_cents - expense_splits.owed_amount_cents")
    end
  end
end
