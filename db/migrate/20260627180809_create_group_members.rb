# frozen_string_literal: true

class CreateGroupMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :group_members do |t|
      t.references :group,      null: false, foreign_key: true
      t.references :user,       null: false, foreign_key: true
      t.references :invited_by, null: true,  foreign_key: { to_table: :users }
      t.integer    :role,       null: false, default: 0, comment: "0:member, 1:admin"
      t.datetime   :joined_at,  null: false

      t.timestamps
    end

    # Prevent duplicate memberships — a user can only be in a group ONCE
    add_index :group_members, [ :group_id, :user_id ], unique: true
  end
end
