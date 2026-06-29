# frozen_string_literal: true

module BlockedUserGuard
  extend ActiveSupport::Concern

  included do
    before_action :require_unblocked_user!, only: [ :new, :create ]
  end

  private

  def require_unblocked_user!
    return unless current_user&.blocked?

    redirect_to root_path,
                alert: "Your account has been blocked. You cannot add expenses or record settlements."
  end
end
