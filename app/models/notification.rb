# frozen_string_literal: true

class Notification < ApplicationRecord
  # ============================================
  # Enums
  # ============================================
  enum :notification_type, {
    expense_added: 0,
    expense_updated: 1,
    expense_deleted: 2,
    settlement_made: 3,
    added_to_group: 4,
    removed_from_group: 5,
    group_invitation: 6,
    payment_reminder: 7
  }

  # ============================================
  # Associations
  # ============================================
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  has_many :notification_recipients, dependent: :destroy
  has_many :recipients, through: :notification_recipients, source: :recipient

  # ============================================
  # Validations
  # ============================================
  validates :notification_type, presence: true
  validates :title, presence: true, length: { maximum: 255 }

  # ============================================
  # Scopes
  # ============================================
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }
end
