# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    before_action :set_user, only: [:show, :block, :unblock, :promote, :demote, :reset_password]

    def index
      @users = User.order(created_at: :desc)
      @users = @users.where("username ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where.not(blocked_at: nil) if params[:blocked] == "true"
    end

    def show
      @groups        = @user.groups.includes(:group_members).order(created_at: :desc)
      @expense_count = @user.created_expenses.count
      @total_spent   = @user.created_expenses.sum(:total_amount_cents) / 100.0
    end

    def block
      return redirect_to admin_users_path, alert: "Admin accounts cannot be blocked." if @user.is_a?(Admin)

      @user.block!
      redirect_to admin_users_path, notice: "#{@user.username} has been blocked."
    end

    def unblock
      @user.unblock!
      redirect_to admin_users_path, notice: "#{@user.username} has been unblocked."
    end

    def promote
      redirect_to new_admin_user_payment_path(@user)
    end

    def demote
      @user.active_subscription&.cancel!
      @user.update!(role: :simple)
      redirect_to admin_users_path, notice: "#{@user.username} demoted to Simple and subscription cancelled."
    end

    def reset_password
      @user.send_reset_password_instructions
      redirect_to admin_users_path, notice: "Password reset email sent to #{@user.email}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
