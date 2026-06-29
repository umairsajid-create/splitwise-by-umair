# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    # Get current user's groups
    @groups = current_user.groups.includes(:group_members).order(created_at: :desc)

    summary = Balances::DashboardSummaryService.new(current_user).call
    @total_balance = summary[:total_balance_cents] / 100.0
    @you_are_owed  = summary[:you_are_owed_cents] / 100.0
    @you_owe       = summary[:you_owe_cents] / 100.0

    # Fetch recent activity (stub)
    @recent_expenses = Expense.where(group: @groups)
                              .includes(:created_by, :group)
                              .order(expense_date: :desc)
                              .limit(5)
  end
end
