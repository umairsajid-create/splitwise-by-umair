# frozen_string_literal: true

class GroupInvitation < ApplicationRecord
  # ============================================
  # Enums
  # ============================================
  enum :status, { pending: 0, accepted: 1, declined: 2, expired: 3 }

  # ============================================
  # Secure Token
  # ============================================
  has_secure_token :token

  # ============================================
  # Associations
  # ============================================
  belongs_to :group
  belongs_to :invited_by, class_name: "User"

  # ============================================
  # Validations
  # ============================================
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email" }
  validates :email, uniqueness: { scope: :group_id, message: "has already been invited to this group" }
  validates :expires_at, presence: true

  # ============================================
  # Callbacks
  # ============================================
  before_validation :set_defaults, on: :create

  # ============================================
  # Scopes
  # ============================================
  scope :active, -> { pending.where("expires_at > ?", Time.current) }

  # ============================================
  # Instance Methods
  # ============================================
  def expired?
    expires_at < Time.current
  end

  def accept!(user)
    transaction do
      accepted!
      group.group_members.create!(user: user, invited_by: invited_by)
    end
  end

  private

  def set_defaults
    self.expires_at ||= 7.days.from_now
  end
end
