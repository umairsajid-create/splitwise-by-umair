# frozen_string_literal: true

module Admin
  class SessionsController < Devise::SessionsController
    layout "admin"

    # Devise::SessionsController inherits from ApplicationController which
    # has `before_action :authenticate_user!`. Skip it so the admin login
    # page is publicly accessible without being redirected to /users/sign_in.
    skip_before_action :authenticate_user!, raise: false

    def create
      # Extract params explicitly to bypass any Devise/Warden params mapping bugs
      email = params.dig(:admin_user, :email)
      password = params.dig(:admin_user, :password)

      # 1. Manually find and verify the user
      admin = AdminUser.find_by(email: email)
      
      if admin&.valid_password?(password)
        # 2. Clear any potentially corrupted session data from previous attempts
        reset_session
        
        # 3. Log the user in explicitly using Devise's sign_in helper
        sign_in(:admin_user, admin)
        
        # 4. Redirect manually to the Admin Dashboard
        redirect_to admin_root_path, notice: "Signed in successfully."
      else
        # 5. Handle invalid credentials
        self.resource = AdminUser.new(email: email)
        flash.now[:alert] = "Invalid Email or password."
        render :new, status: :unprocessable_entity
      end
    end
  end
end
