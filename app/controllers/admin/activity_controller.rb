# frozen_string_literal: true

module Admin
  class ActivityController < BaseController
    def index
      @query = params[:q].to_s.strip
      @can_use_elasticsearch = true # Admins can always search globally
      @using_elasticsearch = @query.present? && @can_use_elasticsearch

      @activities = Admin::ExpensesSearchService.new(
        query: @query,
        page: params[:page],
        use_elasticsearch: @using_elasticsearch
      ).call
    end
  end
end
