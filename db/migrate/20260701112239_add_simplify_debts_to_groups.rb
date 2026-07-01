class AddSimplifyDebtsToGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :simplify_debts, :boolean, default: false, null: false
  end
end
