# frozen_string_literal: true

module Expenses
  class SearchService
    PER_PAGE = 30

    def initialize(user:, query:, use_elasticsearch: true)
      @user              = user
      @query             = query.to_s.strip
      @use_elasticsearch = use_elasticsearch
    end

    def call
      return self.class.default_scope_for(@user) if @query.blank?
      return sql_search unless @use_elasticsearch

      elasticsearch_search
    rescue Searchkick::Error, OpenSearch::Transport::Transport::Error,
           Faraday::ConnectionFailed, Faraday::TimeoutError => e
      Rails.logger.warn("[Expenses::SearchService] Elasticsearch unavailable: #{e.message}")
      sql_search
    end

    def self.default_scope_for(user)
      Expense.active_records
             .joins(:expense_splits)
             .where(expense_splits: { user_id: user.id })
             .includes(:group, :created_by, :paid_by, :expense_splits)
             .order(created_at: :desc)
             .limit(PER_PAGE)
    end

    private

    def elasticsearch_search
      Expense.search(
        @query,
        fields: [
          { title: :word_start },
          { note: :word_start },
          { group_name: :word_start },
          { created_by_name: :word_start }
        ],
        where: {
          status: "active",
          member_ids: @user.id
        },
        order: { created_at: :desc },
        limit: PER_PAGE,
        load: true,
        includes: [ :group, :created_by, :paid_by, :expense_splits ]
      )
    end

    def sql_search
      sanitized = ActiveRecord::Base.sanitize_sql_like(@query)

      Expense.active_records
             .joins(:expense_splits, :group)
             .where(expense_splits: { user_id: @user.id })
             .where(
               "expenses.title ILIKE :q OR expenses.note ILIKE :q OR groups.name ILIKE :q",
               q: "%#{sanitized}%"
             )
             .includes(:group, :created_by, :paid_by, :expense_splits)
             .order(created_at: :desc)
             .limit(PER_PAGE)
    end
  end
end
