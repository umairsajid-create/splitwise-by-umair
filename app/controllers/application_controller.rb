# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include CanCan::ControllerAdditions

  # ============================================
  # Require login for ALL pages by default
  # (individual controllers can skip with: skip_before_action :authenticate_user!)
  # ============================================
  before_action :authenticate_user!

  # ============================================
  # After sign in → go to dashboard (root)
  # After sign out → go to login page
  # ============================================
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def default_url_options
    {
      host: request.host,
      protocol: request.protocol,
      port: request.optional_port
    }.compact
  end
end
