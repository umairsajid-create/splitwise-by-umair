
class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :delete, :destroy ]

  def index
    @groups = current_user.groups.active.order(created_at: :desc)
  end

  def show
    authorize! :read, @group
    @members             = @group.group_members.includes(:user)
    @pending_invitations = @group.invitations.active.order(created_at: :desc)
    @expenses = @group.expenses.active
                      .where(record_type: :expense)
                      .order(expense_date: :desc)
                      .limit(20)
    @balances = Groups::BalanceService.new(@group).call

    # current user net balance in this group
    @my_balance_cents = @balances.find { |b| b[:user] == current_user }&.dig(:balance_cents) || 0

    # compute net between current_user and every other member
    @my_balance_detail = @balances.reject { |b| b[:user] == current_user }.map do |entry|
      other = entry[:user]
      i_owe_other   = compute_bilateral_cents(@group, payer: other, ower: current_user)
      other_owes_me = compute_bilateral_cents(@group, payer: current_user, ower: other)
      net = other_owes_me - i_owe_other   # positive = they owe me, negative = I owe them
      { user: other, net_cents: net }
    end.reject { |b| b[:net_cents] == 0 }
  end

  def new
    authorize! :create, Group
    @group = Group.new
  end

  def create
    authorize! :create, Group
    @group = Groups::CreateService.new(current_user, group_params).call

    if @group.persisted?
      redirect_to @group, notice: "Group \"#{@group.name}\" was created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! :update, @group
  end

  def update
    authorize! :update, @group
    if @group.update(group_params)
      redirect_to @group, notice: "Group updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # help to check if group can be deleted
  def delete
    authorize! :destroy, @group
    @balances           = Groups::BalanceService.new(@group).call
    @unsettled_balances = Groups::DeleteService.unsettled_balances(@group)
    @can_delete         = @unsettled_balances.empty?
  end

  def destroy
    authorize! :destroy, @group
    group_name = Groups::DeleteService.new(group: @group).call
    redirect_to groups_path, notice: "Group \"#{group_name}\" was deleted."
  rescue Groups::DeleteService::Error => e
    redirect_to delete_group_path(@group), alert: e.message
  end

  private

  def set_group
    @group = current_user.groups.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to groups_path, alert: "Group not found or access denied."
  end

  def group_params
    params.require(:group).permit(:name, :group_type, :avatar)
  end

  def compute_bilateral_cents(group, payer:, ower:)
    group.expenses
         .where(status: 0)
         .where("paid_by_id = ? OR (paid_by_id IS NULL AND created_by_id = ?)", payer.id, payer.id)
         .joins(:expense_splits)
         .where(expense_splits: { user_id: ower.id })
         .sum("expense_splits.owed_amount_cents")
  end
end
