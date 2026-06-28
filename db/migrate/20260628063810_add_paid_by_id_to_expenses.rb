class AddPaidByIdToExpenses < ActiveRecord::Migration[8.1]
  def change
    add_column :expenses, :paid_by_id, :bigint
    add_index :expenses, :paid_by_id
  end
end
