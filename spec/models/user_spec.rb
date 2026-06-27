# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:created_groups).class_name("Group").with_foreign_key(:creator_id) }
    it { should have_many(:group_memberships).class_name("GroupMember").dependent(:destroy) }
    it { should have_many(:groups).through(:group_memberships) }
    it { should have_many(:created_expenses).class_name("Expense").with_foreign_key(:created_by_id) }
    it { should have_many(:expense_splits).dependent(:destroy) }
    it { should have_many(:sent_invitations).class_name("GroupInvitation").with_foreign_key(:invited_by_id) }
    it { should have_many(:triggered_notifications).class_name("Notification").with_foreign_key(:actor_id) }
    it { should have_many(:notification_recipients).with_foreign_key(:recipient_id) }
    it { should have_many(:received_notifications).through(:notification_recipients) }
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:default_splits).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_length_of(:username).is_at_least(3).is_at_most(30) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:default_currency) }
    it { should validate_numericality_of(:daily_expense_limit).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:daily_settlement_limit).is_greater_than_or_equal_to(0) }
  end

  describe "enums" do
    it { should define_enum_for(:role).with_values(simple: 0, premium: 1, admin: 2) }
  end

  describe "#premium_or_admin?" do
    it "returns true for premium user" do
      user = build(:user, :premium)
      expect(user.premium_or_admin?).to be true
    end

    it "returns true for admin user" do
      user = build(:user, :admin)
      expect(user.premium_or_admin?).to be true
    end

    it "returns false for simple user" do
      user = build(:user)
      expect(user.premium_or_admin?).to be false
    end
  end
end
