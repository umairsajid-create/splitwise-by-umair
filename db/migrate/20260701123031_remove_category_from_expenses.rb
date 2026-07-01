class RemoveCategoryFromExpenses < ActiveRecord::Migration[8.1]
  def change
    remove_column :expenses, :category, :integer
  end
end
