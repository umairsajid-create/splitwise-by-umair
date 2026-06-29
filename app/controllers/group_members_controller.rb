# frozen_string_literal: true

class GroupMembersController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @group  = current_user.groups.find(params[:group_id])
    @member = @group.group_members.find(params[:id])
    balance_cents = Groups::LeaveService.member_balance_cents(@group, @member.user)

    # can't remove member with outstanding balance in this group
    if balance_cents != 0
      redirect_to @group, alert: "Cannot remove #{@member.user.username} — they have an unsettled balance in this group."
      return
    end

    # Only group admin can remove members
    unless @group.admin?(current_user)
      redirect_to @group, alert: "Only group admins can remove members."
      return
    end

    user = @member.user
    @member.destroy
    Balances::RecalculateService.new(user).call
    redirect_to @group, notice: "Member removed from group."
  end
end
