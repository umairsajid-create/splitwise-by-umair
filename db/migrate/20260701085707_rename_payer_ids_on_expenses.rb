class RenamePayerIdsOnExpenses < ActiveRecord::Migration[8.1]
  def change
    rename_column :expenses, :prayer_ids, :payer_ids
  end
end
