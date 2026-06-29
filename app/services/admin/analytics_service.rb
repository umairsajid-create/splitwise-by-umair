# frozen_string_literal: true

module Admin
  class AnalyticsService
    PERIODS = {
      day:   { count: 14, label: "Last 14 days" },
      week:  { count: 8,  label: "Last 8 weeks" },
      month: { count: 6,  label: "Last 6 months" }
    }.freeze

    def initialize(period: :week)
      @period = PERIODS.key?(period.to_sym) ? period.to_sym : :week
    end

    def call
      {
        period:          @period,
        period_label:    PERIODS[@period][:label],
        totals: {
          users:      User.count,
          groups:     Group.count,
          activities: Expense.where(status: :active).count
        },
        labels:          bucket_labels,
        users_series:    bucket_counts(User),
        groups_series:   bucket_counts(Group),
        activity_series: bucket_counts(Expense.where(status: :active))
      }
    end

    private

    def bucket_starts
      count = PERIODS[@period][:count]
      @bucket_starts ||= (count - 1).downto(0).map do |i|
        case @period
        when :day   then i.days.ago.beginning_of_day
        when :week  then i.weeks.ago.beginning_of_week
        when :month then i.months.ago.beginning_of_month
        end
      end
    end

    def bucket_labels
      bucket_starts.map do |start|
        case @period
        when :day   then start.strftime("%a %d")
        when :week  then "Wk #{start.strftime('%d %b')}"
        when :month then start.strftime("%b %Y")
        end
      end
    end

    def bucket_range(start)
      case @period
      when :day   then start..start.end_of_day
      when :week  then start..start.end_of_week
      when :month then start..start.end_of_month
      end
    end

    def bucket_counts(scope)
      bucket_starts.map { |start| scope.where(created_at: bucket_range(start)).count }
    end
  end
end
