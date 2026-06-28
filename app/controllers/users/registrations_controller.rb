# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def destroy
    if current_user.balance_cents != 0
      flash[:alert] = "You cannot delete your account until all your balances are settled."
      redirect_to edit_user_registration_path
    else
      super
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :default_currency, :phone_number, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :default_currency, :phone_number, :avatar])
  end

  def update_resource(resource, params)
    # Require current password if user is trying to change password.
    if params[:password].present? || params[:email] != resource.email
      resource.update_with_password(params)
    else
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      resource.update_without_password(params)
    end
  end
end
