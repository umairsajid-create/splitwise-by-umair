# frozen_string_literal: true

module Admin
  class AnalyticsController < AdminController
    def index
      @period    = params[:period].presence || "week"
      @analytics = Admin::AnalyticsService.new(period: @period).call
      @latest_users    = User.order(created_at: :desc).limit(5)
      @latest_expenses = Expense.active_records.includes(:group, :created_by).order(created_at: :desc).limit(5)
    end
  end
end
