

class Expense < ApplicationRecord
  # Enums
  enum :record_type, { expense: 0, settlement: 1 }
  enum :category, { general: 0, food: 1, transport: 2, entertainment: 3,
                     utilities: 4, rent: 5, shopping: 6, healthcare: 7, other_category: 8 }
  enum :split_type, { equal: 0, exact: 1, percentage: 2, adjustment: 3 }
  enum :status, { active: 0, deleted: 1, updated: 2 }


  # Active Storage
  has_one_attached :proof

  # Associations
  belongs_to :group
  belongs_to :created_by, class_name: "User"
  belongs_to :paid_by, class_name: "User"
  has_many :expense_splits, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :total_amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :expense_date, presence: true
  validates :record_type, presence: true
  validates :category, presence: true
  validates :split_type, presence: true

  # Scopes
  scope :active_records, -> { where(status: :active) }
  scope :expenses_only, -> { where(record_type: :expense) }
  scope :settlements_only, -> { where(record_type: :settlement) }
  scope :by_date, -> { order(expense_date: :desc) }
  scope :for_date_range, ->(start_date, end_date) { where(expense_date: start_date..end_date) }

  # Instance Methods
  def total_amount
    total_amount_cents / 100.0
  end

  def settlement?
    record_type == "settlement"
  end

  def soft_delete!
    update!(status: :deleted)
  end
end
