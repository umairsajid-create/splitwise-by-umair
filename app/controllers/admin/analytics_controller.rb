# frozen_string_literal: true

module Admin
  class AnalyticsController < BaseController
    def index
      @period    = params[:period].presence || "week"
      @analytics = Admin::AnalyticsService.new(period: @period).call
    end
  end
end
