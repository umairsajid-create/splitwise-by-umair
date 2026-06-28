# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_expense, only: [ :show, :destroy ]

  # GET /groups/:group_id/expenses/new
  def new
    @expense = Expense.new(expense_date: Date.today)
    @members = @group.members
  end

  # POST /groups/:group_id/expenses
  def create
    service = Expenses::CreateService.new(
      group:      @group,
      creator:    current_user,
      params:     expense_params,
      split_data: split_params
    )

    @expense = service.call

    if @expense.persisted?
      redirect_to @group, notice: "Expense \"#{@expense.title}\" added!"
    else
      @members = @group.members
      render :new, status: :unprocessable_entity
    end
  end

  # GET /groups/:group_id/expenses/:id
  def show
    @splits = @expense.expense_splits.includes(:user)
  end

  # DELETE /groups/:group_id/expenses/:id
  def destroy
    Expenses::DeleteService.new(@expense).call
    redirect_to @group, notice: "Expense deleted."
  end

  private

  def set_group
    @group = current_user.groups.find(params[:group_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to groups_path, alert: "Group not found."
  end

  def set_expense
    @expense = @group.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(
      :title, :category, :total_amount_cents, :currency,
      :split_type, :expense_date, :note, :paid_by_id, :proof
    )
  end

  # Expects: splits: { "0" => { user_id: 1, owed_amount_cents: 1000 }, ... }
  def split_params
    splits_hash = params.fetch(:splits, {})
    splits_array = splits_hash.respond_to?(:values) ? splits_hash.values : splits_hash
    
    splits_array.map do |split|
      split.permit(:user_id, :owed_amount_cents)
    end
  end
end
