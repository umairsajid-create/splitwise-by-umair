# frozen_string_literal: true

class ActivityController < ApplicationController
  def index
    # Fetch recent expenses the user is involved in as their "Activity" feed
    @activities = Expense.active_records
                         .joins(:expense_splits)
                         .where(expense_splits: { user_id: current_user.id })
                         .includes(:group, :created_by, :paid_by)
                         .order(created_at: :desc)
                         .limit(30)
    # Mark all unread notifications for this user as read
    current_user.notification_recipients.unread.update_all(read_at: Time.current)
  end
end
