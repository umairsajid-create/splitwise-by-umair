# frozen_string_literal: true

class ExpensesController < ApplicationController
  include BlockedUserGuard # block user from admin side

  before_action :authenticate_user!
  before_action :set_group
  before_action :set_expense, only: [ :show, :destroy ]

  def new
    @expense = Expense.new(expense_date: Date.today)
    @members = @group.members
    @categories_by_section = Category.all.group_by(&:section)
  end

  def create
    raw_params = expense_params
    if raw_params[:total_amount].present?
      raw_params = raw_params.merge(total_amount_cents: (raw_params[:total_amount].to_f * 100).round)
    end
    raw_params = raw_params.except(:total_amount)

    service = Expenses::CreateService.new(
      group:      @group,
      creator:    current_user,
      params:     raw_params,
      split_data: build_split_data(raw_params[:total_amount_cents]),
      payer_data: build_payer_data
    )

    @expense = service.call

    if @expense.persisted?
      redirect_to @group, notice: "Expense \"#{@expense.title}\" added!"
    else
      @members = @group.members
      @categories_by_section = Category.all.group_by(&:section)
      render :new, status: :unprocessable_entity
    end
  end


  def show
    @splits = @expense.expense_splits.includes(:user)
  end

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
      :title, :category_id, :total_amount, :total_amount_cents, :currency,
      :split_type, :expense_date, :note, :paid_by_id, :proof, :is_multi_payer
    )
  end

  # Build split data: use JS-provided cents if available, else split equally
  def build_split_data(total_cents)
    splits_hash = params.fetch(:splits, {})
    splits_array = splits_hash.respond_to?(:values) ? splits_hash.values : splits_hash
    permitted = splits_array.map { |s| s.permit(:user_id, :owed_amount_cents) }

    # Check if JS provided valid split data
    js_sum = permitted.sum { |s| s[:owed_amount_cents].to_i }

    if js_sum > 0
      # JS calculated splits correctly — use them
      permitted
    else
      # JS failed — fall back to equal split among all members
      member_ids = @group.members.pluck(:id)
      count = member_ids.size
      share = total_cents / count rescue 0
      remainder = total_cents - (share * count) rescue 0
      member_ids.each_with_index.map do |uid, i|
        amt = share + (i == 0 ? remainder : 0)
        ActionController::Parameters.new(user_id: uid.to_s, owed_amount_cents: amt.to_s).permit(:user_id, :owed_amount_cents)
      end
    end
  end

  def build_payer_data
    payers_hash  = params.fetch(:payers, {})
    payers_array = payers_hash.respond_to?(:values) ? payers_hash.values : payers_hash
    permitted    = payers_array.map { |p| p.permit(:user_id, :paid_amount_cents) }

    permitted.each_with_object({}) do |p, h|
      h[p[:user_id].to_i] = p[:paid_amount_cents].to_i
    end
  end
end
