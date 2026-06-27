# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user,           null: false, foreign_key: true
      t.integer    :plan,           null: false, default: 0, comment: "0:monthly, 1:yearly"
      t.integer    :status,         null: false, default: 0, comment: "0:active, 1:cancelled, 2:expired, 3:past_due"
      t.integer    :amount_cents,   null: false
      t.string     :currency,       null: false, default: "PKR"
      t.integer    :payment_method, comment: "0:credit_card, 1:debit_card, 2:bank_transfer, 3:wallet"
      t.string     :transaction_id
      t.datetime   :starts_at,      null: false
      t.datetime   :ends_at,        null: false
      t.datetime   :cancelled_at

      t.timestamps
    end

    add_index :subscriptions, :status
    add_index :subscriptions, :ends_at
  end
end
