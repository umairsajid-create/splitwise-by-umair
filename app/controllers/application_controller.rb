# fronzen string litral: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  include CanCan::ControllerAdditions

  # always require login on all the pages
  before_action :authenticate_user!

  # sign in, sign up go to dashboard
  def after_sign_in_path_for(resource)
    if resource.is_a?(Hash) || !resource.respond_to?(:class)
      # If session is corrupted with a Hash, clear it
      sign_out_all_scopes
      return root_path
    end

    if resource.is_a?(AdminUser)
      stored_location_for(resource) || admin_root_path
    else
      stored_location_for(resource) || root_path
    end
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || root_path
  end

  # sign out go to login page
  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :admin_user || resource_or_scope.is_a?(AdminUser)
      new_admin_user_session_path
    else
      new_user_session_path
    end
  end

  # ability
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
