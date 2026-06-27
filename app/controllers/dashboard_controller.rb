# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    # Get current user's groups
    @groups = current_user.groups.includes(:group_members).order(created_at: :desc)
    
    # We will also calculate the total user balances (who owes who)
    # Right now, it's just basic logic that will be expanded in the BalanceService (Branch 4)
    @total_balance = current_user.balance_cents / 100.0 # simple conversion
    
    # Quick stats for the UI
    @you_are_owed = 0.0 # Will calculate from splits later
    @you_owe = 0.0      # Will calculate from splits later

    # Fetch recent activity (stub)
    @recent_expenses = Expense.where(group: @groups)
                              .includes(:created_by, :group)
                              .order(expense_date: :desc)
                              .limit(5)
  end
end
