# frozen_string_literal: true

class WelcomeMailerJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(invitation_id, user_id)
    invitation = GroupInvitation.find_by(id: invitation_id)
    user       = User.find_by(id: user_id)
    # skip if not get the id or invitation expired or accepted etc
    unless invitation && user
      Rails.logger.warn("[WelcomeMailerJob] Missing invitation ##{invitation_id} or user ##{user_id} — skipping.")
      return
    end

    GroupInvitationMailer.welcome_email(invitation, user).deliver_now
    Rails.logger.info("[WelcomeMailerJob] Welcome email sent to #{user.email} for group #{invitation.group.name}")
  end
end
