# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationRecipient, type: :model do
  describe "associations" do
    it { should belong_to(:notification) }
    it { should belong_to(:recipient).class_name("User") }
  end

  describe "validations" do
    subject { build(:notification_recipient) }

    it { should validate_uniqueness_of(:recipient_id).scoped_to(:notification_id).with_message("already received this notification") }
  end

  describe "scopes" do
    let!(:unread) { create(:notification_recipient, read_at: nil) }
    let!(:read) { create(:notification_recipient, :read) }

    it "returns unread notifications" do
      expect(NotificationRecipient.unread).to include(unread)
      expect(NotificationRecipient.unread).not_to include(read)
    end
  end

  describe "#mark_as_read!" do
    it "sets read_at timestamp" do
      recipient = create(:notification_recipient)
      expect(recipient.read_at).to be_nil

      recipient.mark_as_read!
      expect(recipient.read_at).to be_present
    end

    it "does not update if already read" do
      original_time = 1.hour.ago
      recipient = create(:notification_recipient, read_at: original_time)

      recipient.mark_as_read!
      expect(recipient.read_at).to eq(original_time)
    end
  end
end
