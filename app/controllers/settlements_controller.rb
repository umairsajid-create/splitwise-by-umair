# frozen_string_literal: true

class SettlementsController < ApplicationController
  include BlockedUserGuard # block user from admin side

  before_action :authenticate_user!
  before_action :set_group

  def new
    @balances = Groups::BalanceService.new(@group).call


    @members = @group.members.where.not(id: current_user.id)
  end

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
