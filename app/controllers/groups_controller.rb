# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]

  # GET /groups
  def index
    @groups = current_user.groups.active.order(created_at: :desc)
  end

  # GET /groups/:id
  def show
    authorize! :read, @group
    @members  = @group.group_members.includes(:user)
    @expenses = @group.expenses.active
                      .where(record_type: :expense)
                      .order(expense_date: :desc)
                      .limit(20)
    @balances = Groups::BalanceService.new(@group).call

    # My own net balance in this group (positive = others owe me, negative = I owe)
    @my_balance_cents = @balances.find { |b| b[:user] == current_user }&.dig(:balance_cents) || 0

    # Per-member breakdown: what I owe to each person / what each owes me
    # We compute bilateral net between current_user and every other member
    service = Groups::BalanceService.new(@group)
    @my_balance_detail = @balances.reject { |b| b[:user] == current_user }.map do |entry|
      other = entry[:user]
      # Net = what other paid for me minus what I paid for them
      i_owe_other   = compute_bilateral_cents(@group, payer: other, ower: current_user)
      other_owes_me = compute_bilateral_cents(@group, payer: current_user, ower: other)
      net = other_owes_me - i_owe_other   # positive = they owe me, negative = I owe them
      { user: other, net_cents: net }
    end.reject { |b| b[:net_cents] == 0 }
  end

  # GET /groups/new
  def new
    authorize! :create, Group
    @group = Group.new
  end

  # POST /groups
  def create
    authorize! :create, Group
    @group = Groups::CreateService.new(current_user, group_params).call

    if @group.persisted?
      redirect_to @group, notice: "Group \"#{@group.name}\" was created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /groups/:id/edit
  def edit
    authorize! :update, @group
  end

  # PATCH /groups/:id
  def update
    authorize! :update, @group
    if @group.update(group_params)
      redirect_to @group, notice: "Group updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:id
  def destroy
    authorize! :destroy, @group
    @group.archive!
    redirect_to groups_path, notice: "Group archived."
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

  # How much does `ower` owe `payer` in this group?
  # = ower's owed_amount_cents on expenses paid by payer
  def compute_bilateral_cents(group, payer:, ower:)
    group.expenses
         .where(status: 0, paid_by_id: payer.id)
         .joins(:expense_splits)
         .where(expense_splits: { user_id: ower.id })
         .sum("expense_splits.owed_amount_cents")
  end
end
