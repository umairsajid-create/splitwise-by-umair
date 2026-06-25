# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      ## Devise fields
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      ## Custom fields
      t.string  :username,               null: false
      t.string  :phone_number
      t.integer :role,                    null: false, default: 0, comment: "0:simple, 1:premium, 2:admin"
      t.integer :daily_expense_limit,     null: false, default: 5
      t.integer :daily_settlement_limit,  null: false, default: 3
      t.integer :balance_cents,           null: false, default: 0
      t.string  :default_currency,        null: false, default: "PKR"
      t.datetime :last_login_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :username,             unique: true
    add_index :users, :phone_number
    add_index :users, :role
    add_index :users, :reset_password_token, unique: true
  end
end
