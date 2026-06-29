# frozen_string_literal: true

class GroupMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group

  # if user wanna leave group
  def show
    @my_balance_cents = Groups::LeaveService.member_balance_cents(@group, current_user)
    @membership       = @group.group_members.find_by(user: current_user)

    unless @membership
      redirect_to groups_path, alert: "You are not a member of this group."
      return
    end

    @sole_admin_block = @membership.admin? &&
                        @group.group_members.admin.count == 1 &&
                        @group.group_members.count > 1

    @can_leave = @my_balance_cents.zero? && !@sole_admin_block
  end

  # user leave group
  def destroy
    Groups::LeaveService.new(group: @group, user: current_user).call
    redirect_to groups_path, notice: "You have left \"#{@group.name}\"."
  rescue Groups::LeaveService::Error => e
    redirect_to group_membership_path(@group), alert: e.message
  end

  private

  def set_group
    @group = current_user.groups.find(params[:group_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to groups_path, alert: "Group not found or access denied."
  end
end
