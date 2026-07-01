
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

    @my_balance_cents = @balances.find { |b| b[:user] == current_user }&.dig(:balance_cents) || 0

    if @group.simplify_debts?
      # work on net balance not on expense
      creditors = @balances.select { |b| b[:balance_cents] > 0 }.map(&:dup)
      debtors   = @balances.select { |b| b[:balance_cents] < 0 }.map(&:dup)

      transactions = []

      while creditors.any? && debtors.any?
        creditor = creditors.first
        debtor   = debtors.last
        amount = [ creditor[:balance_cents], debtor[:balance_cents].abs ].min

        transactions << { from: debtor[:user], to: creditor[:user], amount: amount }

        creditor[:balance_cents] -= amount
        debtor[:balance_cents]   += amount

        creditors.shift if creditor[:balance_cents] == 0
        debtors.pop     if debtor[:balance_cents]   == 0
      end

      @my_balance_detail = []
      transactions.each do |t|
        if t[:from] == current_user
          @my_balance_detail << { user: t[:to], net_cents: -t[:amount] }
        elsif t[:to] == current_user
          @my_balance_detail << { user: t[:from], net_cents: t[:amount] }
        end
      end
    else
      # work on expense (no cross-expense simplification)
      @my_balance_detail = Groups::BilateralBalancesService.new(@group, current_user).call
    end
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
    params.require(:group).permit(:name, :group_type, :avatar, :simplify_debts)
  end
end
