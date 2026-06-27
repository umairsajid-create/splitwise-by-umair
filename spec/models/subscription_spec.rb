# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:plan) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:amount_cents) }
    it { should validate_numericality_of(:amount_cents).is_greater_than(0) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }

    it "requires ends_at to be after starts_at" do
      sub = build(:subscription, starts_at: Time.current, ends_at: 1.day.ago)
      expect(sub).not_to be_valid
      expect(sub.errors[:ends_at]).to include("must be after start date")
    end
  end

  describe "enums" do
    it { should define_enum_for(:plan).with_values(monthly: 0, yearly: 1) }
    it { should define_enum_for(:status).with_values(active: 0, cancelled: 1, expired: 2, past_due: 3) }
  end

  describe "#days_remaining" do
    it "returns days until expiry for active subscription" do
      sub = build(:subscription, ends_at: 15.days.from_now)
      expect(sub.days_remaining).to be_between(14, 15)
    end

    it "returns 0 for non-active subscription" do
      sub = build(:subscription, :expired)
      expect(sub.days_remaining).to eq(0)
    end
  end

  describe "#cancel!" do
    it "sets status to cancelled and records timestamp" do
      sub = create(:subscription)
      sub.cancel!
      expect(sub.status).to eq("cancelled")
      expect(sub.cancelled_at).to be_present
    end
  end
end
