# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # ============================================
  # Require login for ALL pages by default
  # (individual controllers can skip with: skip_before_action :authenticate_user!)
  # ============================================
  before_action :authenticate_user!

  # ============================================
  # Allow Devise to accept extra user fields
  # (username, phone_number) during sign up + account update
  # ============================================
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # Extra fields allowed on sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :username,
      :phone_number,
      :default_currency
    ])

    # Extra fields allowed on account update
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :username,
      :phone_number,
      :default_currency,
      :avatar
    ])
  end

  # ============================================
  # After sign in → go to dashboard (root)
  # After sign out → go to login page
  # ============================================
  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
