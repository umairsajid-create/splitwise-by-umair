# frozen_string_literal: true

class ActivityController < ApplicationController
  def index
    # Will be fully implemented in Branch 7 (invitations)
    # For now just renders a placeholder view
    @notifications = current_user.notification_recipients
                                 .includes(:notification)
                                 .order(created_at: :desc)
                                 .limit(20)
  end
end
