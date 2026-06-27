# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string     :name,       null: false
      t.integer    :group_type, null: false, default: 0, comment: "0:home, 1:trip, 2:couple, 3:other"
      t.boolean    :is_active,  null: false, default: true

      t.timestamps
    end

    add_index :groups, :is_active
  end
end
