# frozen_string_literal: true

module Admin
  class ExpensesSearchService
    PER_PAGE = 30

    def initialize(query:, page: 1, use_elasticsearch: true)
      @query             = query.to_s.strip
      @page              = page || 1
      @use_elasticsearch = use_elasticsearch
    end

    def call
      return default_scope if @query.blank?
      return sql_search unless @use_elasticsearch

      elasticsearch_search
    rescue Searchkick::Error, OpenSearch::Transport::Transport::Error,
           Faraday::ConnectionFailed, Faraday::TimeoutError => e
      Rails.logger.warn("[Admin::ExpensesSearchService] Elasticsearch unavailable: #{e.message}")
      sql_search
    end

    private

    def default_scope
      Expense.active_records
             .includes(:group, :created_by, :paid_by, :expense_splits)
             .order(created_at: :desc)
             .page(@page)
             .per(PER_PAGE)
    end

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
          status: "active"
        },
        order: { created_at: :desc },
        page: @page,
        per_page: PER_PAGE,
        load: true,
        includes: [ :group, :created_by, :paid_by, :expense_splits ]
      )
    end

    def sql_search
      sanitized = ActiveRecord::Base.sanitize_sql_like(@query)

      Expense.active_records
             .joins(:group)
             .where(
               "expenses.title ILIKE :q OR expenses.note ILIKE :q OR groups.name ILIKE :q",
               q: "%#{sanitized}%"
             )
             .includes(:group, :created_by, :paid_by, :expense_splits)
             .order(created_at: :desc)
             .page(@page)
             .per(PER_PAGE)
    end
  end
end
