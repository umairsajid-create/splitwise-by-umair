# frozen_string_literal: true

module Admin
  class AccountController < BaseController
    def show
      @admin = current_admin_user
    end

    def update
      @admin = current_admin_user
      if params[:admin_user][:password].present?
        # Changing password — Devise requires current_password
        if @admin.update_with_password(account_params)
          bypass_sign_in(@admin)
          redirect_to admin_account_path, notice: "Password updated successfully."
        else
          render :show, status: :unprocessable_entity
        end
      else
        if @admin.update(account_params.except(:password, :password_confirmation, :current_password))
          redirect_to admin_account_path, notice: "Account updated successfully."
        else
          render :show, status: :unprocessable_entity
        end
      end
    end

    private

    def account_params
      params.require(:admin_user).permit(:username, :email, :password, :password_confirmation, :current_password)
    end
  end
end
