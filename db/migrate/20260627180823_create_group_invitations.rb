# frozen_string_literal: true

class CreateGroupInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :group_invitations do |t|
      t.references :group,      null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string     :email,      null: false
      t.string     :token,      null: false
      t.integer    :status,     null: false, default: 0, comment: "0:pending, 1:accepted, 2:declined, 3:expired"
      t.datetime   :expires_at, null: false

      t.timestamps
    end

    # One pending invite per email per group
    add_index :group_invitations, [ :group_id, :email ], unique: true
    add_index :group_invitations, :token, unique: true
    add_index :group_invitations, :status
  end
end
