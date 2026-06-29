# frozen_string_literal: true

class SettlementsController < ApplicationController
  include BlockedUserGuard

  before_action :authenticate_user!
  before_action :set_group

  # GET /groups/:group_id/settlements/new
  def new
    # Show members who you owe money to in this group
    @balances = Groups::BalanceService.new(@group).call
    @you_owe  = @balances.select { |b| b[:balance_cents] < 0 } # Wait, if YOU owe them, YOUR balance is negative. But we need to find who YOU owe.
    # Actually, in Splitwise, it's simpler to just let you select anyone, but the list should prioritize who you owe.
    # Let's just list everyone except yourself for simplicity.
    @members = @group.members.where.not(id: current_user.id)
  end

  # POST /groups/:group_id/settlements
  def create
    receiver = User.find(params[:receiver_id])

    settlement = Settlements::CreateService.new(
      group:        @group,
      payer:        current_user,
      receiver:     receiver,
      amount_cents: (params[:amount].to_f * 100).to_i,
      currency:     params[:currency] || current_user.default_currency,
      proof:        params[:proof]
    ).call

    redirect_to @group, notice: "Settlement recorded!"
  rescue => e
    redirect_to new_group_settlement_path(@group), alert: e.message
  end

  private

  def set_group
    @group = current_user.groups.find(params[:group_id])
  end
end
