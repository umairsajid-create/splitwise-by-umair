# frozen_string_literal: true

module Expenses
  class DeleteService
    def initialize(expense)
      @expense = expense
    end

    def call
      user_ids = @expense.expense_splits.pluck(:user_id)

      Expense.transaction do
        @expense.update!(status: :deleted)   # Soft delete
        recalculate_balances(user_ids)
      end

      true
    end

    private

    def recalculate_balances(user_ids)
      User.where(id: user_ids).each do |user|
        Balances::RecalculateService.new(user).call
      end
    end
  end
end
