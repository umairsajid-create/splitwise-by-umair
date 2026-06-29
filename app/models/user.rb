# frozen_string_literal: true

class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum :role, { simple: 0, premium: 1, admin: 2 }

  # Active Storage
  has_one_attached :avatar

  # Associations
  # Groups
  has_many :created_groups, class_name: "Group", foreign_key: :creator_id, dependent: :nullify
  has_many :group_memberships, class_name: "GroupMember", dependent: :destroy
  has_many :groups, through: :group_memberships

  # Expenses
  has_many :created_expenses, class_name: "Expense", foreign_key: :created_by_id, dependent: :nullify
  has_many :expense_splits, dependent: :destroy

  # Invitations
  has_many :sent_invitations, class_name: "GroupInvitation", foreign_key: :invited_by_id, dependent: :nullify

  # Notifications
  has_many :triggered_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :destroy
  has_many :notification_recipients, foreign_key: :recipient_id, dependent: :destroy
  has_many :received_notifications, through: :notification_recipients, source: :notification

  # Subscriptions
  has_many :subscriptions, dependent: :destroy
  has_many :default_splits, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 30 }
  validates :phone_number, length: { maximum: 20 }, allow_blank: true
  validates :role, presence: true
  validates :daily_expense_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :daily_settlement_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :default_currency, presence: true

  # Scopes
  scope :premium_users, -> { where(role: :premium) }
  scope :admins, -> { where(role: :admin) }
  scope :simple_users, -> { where(role: :simple) }

  # Instance Methods
  def premium_or_admin?
    premium? || admin?
  end

  def can_create_expense_today?
    return true if daily_expense_limit.zero?

    today_count = created_expenses.expense.where("DATE(created_at) = ?", Date.current).count
    today_count < daily_expense_limit
  end

  def can_create_settlement_today?
    return true if daily_settlement_limit.zero?

    today_count = created_expenses.settlement.where("DATE(created_at) = ?", Date.current).count
    today_count < daily_settlement_limit
  end

  def active_subscription
    subscriptions.currently_active.order(created_at: :desc).first
  end

  def has_active_subscription?
    active_subscription.present?
  end

  def unread_notification_count
    notification_recipients.unread.count
  end
end
