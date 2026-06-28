# frozen_string_literal: true

class GroupMembersController < ApplicationController
  before_action :authenticate_user!

  # DELETE /groups/:group_id/group_members/:id
  def destroy
    @group  = current_user.groups.find(params[:group_id])
    @member = @group.group_members.find(params[:id])

    # Safety check: can't remove member with outstanding balance
    if @member.balance_cents != 0
      redirect_to @group, alert: "Cannot remove member — they have an active balance."
      return
    end

    # Only group admin can remove members
    unless @group.admin?(current_user)
      redirect_to @group, alert: "Only group admins can remove members."
      return
    end

    @member.destroy
    redirect_to @group, notice: "Member removed from group."
  end
end
