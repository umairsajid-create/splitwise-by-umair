# frozen_string_literal: true

module Invitations
  class SendService
    class Error < StandardError; end

    def initialize(group:, invited_by:, email:)
      @group      = group
      @invited_by = invited_by
      @email      = email.to_s.downcase.strip
    end

    def call
      raise Error, "Please enter an email address." if @email.blank?

      user = User.find_by(email: @email)
      if user && @group.members.include?(user)
        raise Error, "#{@email} is already a member of this group."
      end

      existing = @group.invitations.find_by(email: @email)
      return existing if existing&.pending?

      if existing
        existing.destroy!
      end

      @group.invitations.create!(
        invited_by:  @invited_by,
        email:       @email,
        status:      :pending,
        expires_at:  7.days.from_now
      )
    end
  end
end
