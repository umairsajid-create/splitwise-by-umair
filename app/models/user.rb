# frozen_string_literal: true

class User < ApplicationRecord
  # ============================================
  # Devise modules
  # ============================================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ============================================
  # Enums
  # ============================================
  enum :role, { simple: 0, premium: 1, admin: 2 }

  # ============================================
  # Active Storage
  # ============================================
  has_one_attached :avatar

  # ============================================
  # Validations
  # ============================================
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 }
  validates :phone_number, length: { maximum: 20 }, allow_blank: true
  validates :role, presence: true
  validates :daily_expense_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :daily_settlement_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :default_currency, presence: true

  # ============================================
  # Associations (we'll add more as we create other models)
  # ============================================
  # has_many :created_groups      → added when Group model is created
  # has_many :group_memberships   → added when GroupMember model is created
  # has_many :expense_splits      → added when ExpenseSplit model is created
  # has_many :subscriptions       → added when Subscription model is created

  # ============================================
  # Instance Methods
  # ============================================
  def premium_or_admin?
    premium? || admin?
  end

  def can_create_expense_today?
    return true if daily_expense_limit.zero? # unlimited

    today_count = Expense.where(created_by_id: id, record_type: :expense)
                         .where("DATE(created_at) = ?", Date.current)
                         .count
    today_count < daily_expense_limit
  end

  def can_create_settlement_today?
    return true if daily_settlement_limit.zero? # unlimited

    today_count = Expense.where(created_by_id: id, record_type: :settlement)
                         .where("DATE(created_at) = ?", Date.current)
                         .count
    today_count < daily_settlement_limit
  end
end
