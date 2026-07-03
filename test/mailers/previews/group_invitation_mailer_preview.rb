# frozen_string_literal: true

# Mail preview — accessible at:
#   http://localhost:3000/rails/mailers/
class GroupInvitationMailerPreview < ActionMailer::Preview
  def invite_email
    invitation = GroupInvitation.pending.includes(:group, :invited_by).first
    invitation ||= stub_invitation
    GroupInvitationMailer.invite_email(invitation)
  end

  def welcome_email
    invitation = GroupInvitation.accepted.includes(:group, :invited_by).first
    invitation ||= stub_invitation
    user = User.first || stub_user
    GroupInvitationMailer.welcome_email(invitation, user)
  end

  private

  def stub_invitation
    group   = Group.first   || stub_group
    inviter = User.first    || stub_user

    inv = GroupInvitation.new(
      id:         0,
      group:      group,
      invited_by: inviter,
      email:      "preview@example.com",
      status:     :pending,
      expires_at: 7.days.from_now
    )
    # Override the token reader so URL helpers work without a DB-persisted record
    inv.define_singleton_method(:token) { "preview_token_demo_abc123" }
    inv
  end

  def stub_group
    Group.new(id: 0, name: "Holiday Trip 🏖️", group_type: :trip)
  end

  def stub_user
    User.new(id: 0, username: "umair", email: "umair454755@gmail.com")
  end
end
