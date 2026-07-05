# frozen_string_literal: true

module Admin
  class UsersController < BaseController
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
      @user.update!(role: :premium)
      redirect_to admin_users_path, notice: "#{@user.username} promoted to Premium."
    end

    def demote
      @user.update!(role: :simple)
      redirect_to admin_users_path, notice: "#{@user.username} demoted to Simple."
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
