# frozen_string_literal: true

class CreateNotificationRecipients < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_recipients do |t|
      t.references :notification, null: false, foreign_key: true
      t.references :recipient,    null: false, foreign_key: { to_table: :users }
      t.datetime   :read_at

      t.timestamps
    end

    # One delivery per recipient per notification
    add_index :notification_recipients, [ :notification_id, :recipient_id ],
              unique: true, name: "idx_notif_recipients_on_notif_and_recipient"

    # Fast query: "get all unread notifications for user X"
    add_index :notification_recipients, [ :recipient_id, :read_at ],
              name: "idx_notif_recipients_on_recipient_and_read"
  end
end
