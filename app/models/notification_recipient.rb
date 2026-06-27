# frozen_string_literal: true

class NotificationRecipient < ApplicationRecord
  # ============================================
  # Associations
  # ============================================
  belongs_to :notification
  belongs_to :recipient, class_name: "User"

  # ============================================
  # Validations
  # ============================================
  validates :recipient_id, uniqueness: { scope: :notification_id,
                                          message: "already received this notification" }

  # ============================================
  # Scopes
  # ============================================
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  # ============================================
  # Instance Methods
  # ============================================
  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end
end
