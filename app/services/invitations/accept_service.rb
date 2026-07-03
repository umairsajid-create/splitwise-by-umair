# frozen_string_literal: true

module Invitations
  class AcceptService
    def initialize(token:, user:)
      @token = token
      @user  = user
    end

    def call
      invitation = GroupInvitation.find_by!(token: @token)

      if invitation.expired?
        invitation.update!(status: :expired)
        raise "This invitation has expired."
      end

      if invitation.accepted?
        raise "This invitation has already been accepted."
      end

      GroupInvitation.transaction do
        invitation.group.group_members.find_or_create_by!(user: @user) do |gm|
          gm.invited_by = invitation.invited_by
          gm.role       = :member
          gm.joined_at  = Time.current
        end
        invitation.update!(status: :accepted)
      end

      # Enqueue welcome email to the user who just joined (async via Sidekiq)
      WelcomeMailerJob.perform_later(invitation.id, @user.id)

      invitation.group
    end
  end
end
