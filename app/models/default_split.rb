# frozen_string_literal: true

class DefaultSplit < ApplicationRecord
  # ============================================
  # Enums
  # ============================================
  enum :split_type, { equal: 0, exact: 1, percentage: 2, adjustment: 3 }

  # ============================================
  # Associations
  # ============================================
  belongs_to :user
  belongs_to :group

  # ============================================
  # Validations
  # ============================================
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :split_type, presence: true
  validates :split_config, presence: true
end
