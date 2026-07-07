# frozen_string_literal: true

module Admin
  class ExpensesController < AdminController
    def index
      @expenses = Expense.includes(:group, :created_by, :category)
                         .active_records
                         .by_date

      @expenses = @expenses.where(group_id: params[:group_id]) if params[:group_id].present?
      @expenses = @expenses.where(record_type: params[:record_type]) if params[:record_type].present?
      @expenses = @expenses.where("expense_date >= ?", params[:from].to_date) if params[:from].present?
      @expenses = @expenses.where("expense_date <= ?", params[:to].to_date)   if params[:to].present?

      @total_cents    = @expenses.sum(:total_amount_cents)
      @expenses       = @expenses.limit(100)
    end

    def destroy
      expense = Expense.find(params[:id])
      expense.soft_delete!
      redirect_to admin_expenses_path, notice: "Expense \"#{expense.title}\" removed."
    end
  end
end
