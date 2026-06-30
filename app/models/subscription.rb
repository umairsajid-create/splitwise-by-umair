# frozen_string_literal: true

class Subscription < ApplicationRecord
  enum :plan, { monthly: 0, yearly: 1 }
  enum :status, { active: 0, cancelled: 1, expired: 2, past_due: 3 }
  enum :payment_method, { credit_card: 0, debit_card: 1, bank_transfer: 2, wallet: 3 }

  belongs_to :user
  validates :plan, presence: true
  validates :status, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_at_after_starts_at

  scope :currently_active, -> { active.where("ends_at > ?", Time.current) }
  scope :expired_unchecked, -> { active.where("ends_at <= ?", Time.current) }

  # Instance Methods
  def amount
    amount_cents / 100.0
  end

  def days_remaining
    return 0 unless active?

    (ends_at.to_date - Date.current).to_i
  end

  def cancel!
    update!(status: :cancelled, cancelled_at: Time.current)
  end

  private

  def ends_at_after_starts_at
    return unless starts_at.present? && ends_at.present?

    if ends_at <= starts_at
      errors.add(:ends_at, "must be after start date")
    end
  end
end
