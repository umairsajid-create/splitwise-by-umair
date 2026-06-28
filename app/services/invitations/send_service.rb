# frozen_string_literal: true

module Invitations
  class SendService
    def initialize(group:, invited_by:, email:)
      @group      = group
      @invited_by = invited_by
      @email      = email.downcase.strip
    end

    def call
      # Prevent duplicate invitations
      existing = @group.invitations.pending.find_by(email: @email)
      return existing if existing.present?

      @group.invitations.create!(
        invited_by:  @invited_by,
        email:       @email,
        status:      :pending,
        expires_at:  7.days.from_now
      )
      # Email is sent via Sidekiq job (we will add this in Phase 3 with AWS SES)
    end
  end
end
