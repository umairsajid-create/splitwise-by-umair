# frozen_string_literal: true

class CreateDefaultSplits < ActiveRecord::Migration[8.1]
  def change
    create_table :default_splits do |t|
      t.references :user,       null: false, foreign_key: true
      t.references :group,      null: false, foreign_key: true
      t.string     :name,       null: false
      t.integer    :split_type, null: false, default: 0, comment: "0:equal, 1:exact, 2:percentage, 3:adjustment"
      t.jsonb      :split_config, null: false, default: {}

      t.timestamps
    end

    add_index :default_splits, [ :user_id, :group_id ]
  end
end
