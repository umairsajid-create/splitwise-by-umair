# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @users = User.order(created_at: :desc)
    end

    def block
      @user = User.find(params[:id])
      return redirect_to admin_users_path, alert: "You cannot block yourself." if @user == current_user
      return redirect_to admin_users_path, alert: "Admin accounts cannot be blocked." if @user.admin?

      @user.block!
      redirect_to admin_users_path, notice: "#{@user.username} has been blocked."
    end

    def unblock
      @user = User.find(params[:id])
      @user.unblock!
      redirect_to admin_users_path, notice: "#{@user.username} has been unblocked."
    end
  end
end
