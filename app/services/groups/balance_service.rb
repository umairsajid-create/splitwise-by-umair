# frozen_string_literal: true

module Groups
  class BalanceService
    def initialize(group)
      @group = group
    end

    # Returns array sorted by balance: biggest owed first
    # Each element: { user: User, balance_cents: Integer }
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
      # SUM of (paid - owed) for all expense splits in this group
      @group.expenses.active.joins(:expense_splits)
            .where(expense_splits: { user_id: user.id })
            .sum("expense_splits.paid_amount_cents - expense_splits.owed_amount_cents")
    end
  end
end
