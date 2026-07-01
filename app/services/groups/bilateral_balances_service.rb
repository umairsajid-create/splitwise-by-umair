# frozen_string_literal: true

module Groups
  class BilateralBalancesService
    def initialize(group, current_user)
      @group        = group
      @current_user = current_user
    end

    def call
      # This will store how much each other user owes @current_user
      balances = Hash.new(0)

      # Iterate every active expense
      @group.expenses.where(status: 0).includes(expense_splits: :user).find_each do |expense|
        splits = expense.expense_splits.to_a

        user_nets = splits.map do |s|
          { user: s.user, net: s.paid_amount_cents - s.owed_amount_cents }
        end

        creditors = user_nets.select { |n| n[:net] > 0 }.map(&:dup)
        debtors   = user_nets.select { |n| n[:net] < 0 }.map(&:dup)

        # Settle the specific expense internally
        while creditors.any? && debtors.any?
          creditor = creditors.first
          debtor   = debtors.last # highest negative amount (since it's not sorted, just iterate)

          amount = [ creditor[:net], debtor[:net].abs ].min

          # Only care about transactions involving the current_user
          if debtor[:user] == @current_user
            balances[creditor[:user]] -= amount
          elsif creditor[:user] == @current_user
            balances[debtor[:user]] += amount
          end

          creditor[:net] -= amount
          debtor[:net]   += amount

          creditors.shift if creditor[:net] == 0
          debtors.pop     if debtor[:net] == 0
        end
      end

      # Format the output identically to the simplified debt output
      balances.reject { |_, v| v == 0 }.map do |other_user, net|
        { user: other_user, net_cents: net }
      end
    end
  end
end
