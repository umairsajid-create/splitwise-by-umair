# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:actor).class_name("User") }
    it { should belong_to(:notifiable) }
    it { should have_many(:notification_recipients).dependent(:destroy) }
    it { should have_many(:recipients).through(:notification_recipients) }
  end

  describe "validations" do
    it { should validate_presence_of(:notification_type) }
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
  end

  describe "enums" do
    it { should define_enum_for(:notification_type).with_values(
      expense_added: 0, expense_updated: 1, expense_deleted: 2,
      settlement_made: 3, added_to_group: 4, removed_from_group: 5,
      group_invitation: 6, payment_reminder: 7
    ) }
  end
end
