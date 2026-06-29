# frozen_string_literal: true

module Expenses
  class ReindexJob < ApplicationJob
    queue_as :default

    def perform(expense_id)
      expense = Expense.find_by(id: expense_id)
      return unless expense

      if expense.should_index?
        expense.reindex
      else
        Expense.searchkick_index.remove(expense)
      end
    end
  end
end
