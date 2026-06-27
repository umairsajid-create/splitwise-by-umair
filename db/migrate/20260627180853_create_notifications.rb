# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :actor,     null: false, foreign_key: { to_table: :users }
      t.integer    :notification_type, null: false, comment: "0:expense_added, 1:expense_updated, etc."
      t.string     :notifiable_type,   null: false
      t.bigint     :notifiable_id,     null: false
      t.string     :title,             null: false
      t.text       :body

      t.timestamps
    end

    # Polymorphic index — find all notifications for a specific record
    add_index :notifications, [ :notifiable_type, :notifiable_id ]
    add_index :notifications, :notification_type
    add_index :notifications, :created_at
  end
end
