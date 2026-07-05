# frozen_string_literal: true

module Admin
  class InvitationsController < BaseController
    before_action :set_invitation, only: [:expire]

    def index
      @invitations = GroupInvitation.includes(:group, :invited_by)
                                    .order(created_at: :desc)

      @invitations = @invitations.where(status: params[:status]) if params[:status].present?

      @counts = {
        pending:  GroupInvitation.pending.count,
        accepted: GroupInvitation.accepted.count,
        declined: GroupInvitation.declined.count,
        expired:  GroupInvitation.expired.count
      }
    end

    def expire
      if @invitation.pending?
        @invitation.update!(status: :expired)
        redirect_to admin_invitations_path, notice: "Invitation to #{@invitation.email} expired."
      else
        redirect_to admin_invitations_path, alert: "Invitation is already #{@invitation.status}."
      end
    end

    private

    def set_invitation
      @invitation = GroupInvitation.find(params[:id])
    end
  end
end
