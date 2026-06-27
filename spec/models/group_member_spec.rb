# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMember, type: :model do
  describe "associations" do
    it { should belong_to(:group) }
    it { should belong_to(:user) }
    it { should belong_to(:invited_by).class_name("User").optional }
  end

  describe "validations" do
    subject { build(:group_member) }

    it "requires joined_at to be present (set by callback if nil)" do
      member = build(:group_member)
      member.valid?
      expect(member.joined_at).to be_present
    end

    it { should validate_uniqueness_of(:user_id).scoped_to(:group_id).with_message("is already a member of this group") }
  end

  describe "enums" do
    it { should define_enum_for(:role).with_values(member: 0, admin: 1) }
  end

  describe "callbacks" do
    it "sets joined_at automatically on create" do
      member = build(:group_member, joined_at: nil)
      member.valid?
      expect(member.joined_at).to be_present
    end
  end
end
