# frozen_string_literal: true

class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :group,      null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer    :record_type,        null: false, default: 0, comment: "0:expense, 1:settlement"
      t.integer    :category,           null: false, default: 0, comment: "0:general, 1:food, 2:transport, etc."
      t.string     :title,              null: false
      t.text       :note
      t.integer    :total_amount_cents, null: false
      t.string     :currency,           null: false, default: "PKR"
      t.integer    :split_type,         null: false, default: 0, comment: "0:equal, 1:exact, 2:percentage, 3:adjustment"
      t.date       :expense_date,       null: false
      t.integer    :status,             null: false, default: 0, comment: "0:active, 1:deleted, 2:updated"

      t.timestamps
    end

    add_index :expenses, :record_type
    add_index :expenses, :category
    add_index :expenses, :status
    add_index :expenses, :expense_date
  end
end
