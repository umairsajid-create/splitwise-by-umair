# frozen_string_literal: true

class NotificationRecipient < ApplicationRecord
  belongs_to :notification
  belongs_to :recipient, class_name: "User"

  validates :recipient_id, uniqueness: { scope: :notification_id,
                                          message: "already received this notification" }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end
end
