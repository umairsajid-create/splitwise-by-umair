# frozen_string_literal: true

class AdminController < ActionController::Base
  layout "admin"

  before_action :authenticate_admin_user!
  before_action :set_nav_badges

  def current_admin_user
    begin
      user = warden.authenticate(scope: :admin_user)
    rescue ArgumentError => e
      # Devise's Session strategy crashes if the session key is a Hash with 5 elements
      # (it expands *hash into 5 arguments, but expects 2). If this happens, the session is corrupted.
      request.session.delete("warden.user.admin_user.key")
      user = nil
    end

    if user.is_a?(Hash)
      @current_admin_user ||= AdminUser.find_by(email: user["email"]) || AdminUser.find_by(id: user["id"])
    else
      @current_admin_user ||= user
    end
  end
  helper_method :current_admin_user

  protect_from_forgery with: :exception

  private

  def authenticate_admin_user!
    unless current_admin_user
      redirect_to new_admin_user_session_path, alert: "Please sign in to access the admin panel."
    end
  end

  # Loads badge counts shown in the sidebar nav
  def set_nav_badges
    @nav_blocked_count   = User.where.not(blocked_at: nil).count
    @nav_pending_invites = GroupInvitation.pending.count
  end
end
