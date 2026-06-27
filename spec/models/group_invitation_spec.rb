# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupInvitation, type: :model do
  describe "associations" do
    it { should belong_to(:group) }
    it { should belong_to(:invited_by).class_name("User") }
  end

  describe "validations" do
    subject { build(:group_invitation) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).scoped_to(:group_id).with_message("has already been invited to this group") }

    it "requires expires_at to be present (set by callback if nil)" do
      invitation = build(:group_invitation)
      invitation.valid?
      expect(invitation.expires_at).to be_present
    end
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(pending: 0, accepted: 1, declined: 2, expired: 3) }
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      invitation = build(:group_invitation, expires_at: 1.day.ago)
      expect(invitation.expired?).to be true
    end

    it "returns false when expires_at is in the future" do
      invitation = build(:group_invitation, expires_at: 7.days.from_now)
      expect(invitation.expired?).to be false
    end
  end

  describe "token generation" do
    it "generates a token automatically" do
      invitation = create(:group_invitation)
      expect(invitation.token).to be_present
      expect(invitation.token.length).to be >= 20
    end
  end
end
