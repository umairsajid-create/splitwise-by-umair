# frozen_string_literal: true

class InvitationMailerJob < ApplicationJob
  queue_as :mailers

  # Retry up to 3 times
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(invitation_id)
    invitation = GroupInvitation.find_by(id: invitation_id)

    # skip if not get the id
    unless invitation
      Rails.logger.warn("[InvitationMailerJob] Invitation ##{invitation_id} not found — skipping.")
      return
    end

    # skip if accepted or rejected or expired
    unless invitation.pending?
      Rails.logger.info("[InvitationMailerJob] Invitation ##{invitation_id} is #{invitation.status} — skipping mail.")
      return
    end

    GroupInvitationMailer.invite_email(invitation).deliver_now
    Rails.logger.info("[InvitationMailerJob] Invitation email sent for invitation ##{invitation_id} to #{invitation.email}")
  end
end
