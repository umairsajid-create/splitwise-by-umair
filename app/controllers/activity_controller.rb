# frozen_string_literal: true

class ActivityController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @can_use_elasticsearch = can?(:search, Expense)
    @using_elasticsearch = @query.present? && @can_use_elasticsearch

    @activities = Expenses::SearchService.new(
      user:              current_user,
      query:             @query,
      use_elasticsearch: @using_elasticsearch
    ).call

    current_user.notification_recipients.unread.update_all(read_at: Time.current)
  end
end
