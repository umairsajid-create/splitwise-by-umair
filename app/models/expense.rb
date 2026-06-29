

class Expense < ApplicationRecord
  # Enums — instance_methods: false on record_type avoids predicate conflicts on reload
  unless defined_enums.key?("record_type")
    enum :record_type, { expense: 0, settlement: 1 }, instance_methods: false
  end
  unless defined_enums.key?("category")
    enum :category, { general: 0, food: 1, transport: 2, entertainment: 3,
                       utilities: 4, rent: 5, shopping: 6, healthcare: 7, other_category: 8 }
  end
  unless defined_enums.key?("split_type")
    enum :split_type, { equal: 0, exact: 1, percentage: 2, adjustment: 3 }
  end
  unless defined_enums.key?("status")
    enum :status, { active: 0, deleted: 1, updated: 2 }
  end

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

  searchkick word_start: [ :title, :note, :group_name, :created_by_name ],
             filterable: [ :status, :record_type, :group_id, :member_ids ],
             callbacks: false

  scope :search_import, -> { includes(:group, :created_by, :paid_by, :expense_splits) }

  def soft_delete!
    update!(status: :deleted)
    Expenses::ReindexJob.perform_later(id) unless Rails.env.test?
  end

  def search_data
    {
      title: title,
      note: note.to_s,
      category: category,
      currency: currency,
      total_amount_cents: total_amount_cents,
      record_type: record_type,
      status: status,
      group_id: group_id,
      group_name: group.name,
      created_by_name: created_by.username,
      paid_by_name: paid_by&.username.to_s,
      expense_date: expense_date,
      created_at: created_at,
      member_ids: expense_splits.map(&:user_id)
    }
  end

  def should_index?
    active?
  end

  def self.reindex_async(expense)
    return if Rails.env.test?

    Expenses::ReindexJob.perform_later(expense.id)
  end
end
