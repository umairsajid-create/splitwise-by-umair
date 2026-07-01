class AddCategoryIdToExpenses < ActiveRecord::Migration[8.1]
  def change
    add_column :expenses, :category_id, :integer
  end
end
