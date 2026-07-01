class AddMultiPayerToExpenses < ActiveRecord::Migration[8.1]
  def change
    # use to add partial paid in expense
    add_column :expenses, :is_multi_payer, :boolean, default: false, null: false
    add_column :expenses, :prayer_ids, :integer, array: true, default: []
    add_index :expenses, :prayer_ids, using: :gin
  end
end
