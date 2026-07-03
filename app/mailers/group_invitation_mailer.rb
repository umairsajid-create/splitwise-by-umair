# frozen_string_literal: true

class GroupInvitationMailer < ApplicationMailer
  # Sends a group invitation email to the invitee.
  def invite_email(invitation)
    @invitation  = invitation
    @group       = invitation.group
    @invited_by  = invitation.invited_by
    @accept_url  = accept_invitation_url(token: invitation.token)
    @expires_at  = invitation.expires_at.strftime("%B %d, %Y")

    mail(
      to:      invitation.email,
      subject: "#{@invited_by.username} invited you to join \"#{@group.name}\" on Splitwise"
    )
  end

  # Sends a welcome email after the user has accepted the invitation and joined the group.
  def welcome_email(invitation, user)
    @invitation = invitation
    @group      = invitation.group
    @user       = user
    @group_url  = group_url(@group)

    mail(
      to:      user.email,
      subject: "Welcome to \"#{@group.name}\" on Splitwise! 🎉"
    )
  end
end
