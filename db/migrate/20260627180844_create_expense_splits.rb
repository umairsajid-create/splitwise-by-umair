# frozen_string_literal: true

class CreateExpenseSplits < ActiveRecord::Migration[8.1]
  def change
    create_table :expense_splits do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :user,    null: false, foreign_key: true
      t.integer    :owed_amount_cents, null: false, default: 0
      t.integer    :paid_amount_cents, null: false, default: 0

      t.timestamps
    end

    # One split per user per expense
    add_index :expense_splits, [ :expense_id, :user_id ], unique: true
  end
end
