# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group, type: :model do
  describe "associations" do
    it { should belong_to(:creator).class_name("User") }
    it { should have_many(:group_members).dependent(:destroy) }
    it { should have_many(:members).through(:group_members) }
    it { should have_many(:expenses).dependent(:destroy) }
    it { should have_many(:invitations).class_name("GroupInvitation").dependent(:destroy) }
    it { should have_many(:default_splits).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should validate_presence_of(:group_type) }
  end

  describe "enums" do
    it { should define_enum_for(:group_type).with_values(home: 0, trip: 1, couple: 2, other: 3) }
  end

  describe "scopes" do
    let!(:active_group) { create(:group, is_active: true) }
    let!(:archived_group) { create(:group, :archived) }

    it "returns active groups" do
      expect(Group.active).to include(active_group)
      expect(Group.active).not_to include(archived_group)
    end

    it "returns archived groups" do
      expect(Group.archived).to include(archived_group)
      expect(Group.archived).not_to include(active_group)
    end
  end

  describe "#member?" do
    it "returns true if user is a member" do
      group = create(:group)
      user = create(:user)
      create(:group_member, group: group, user: user)
      expect(group.member?(user)).to be true
    end

    it "returns false if user is not a member" do
      group = create(:group)
      user = create(:user)
      expect(group.member?(user)).to be false
    end
  end
end
