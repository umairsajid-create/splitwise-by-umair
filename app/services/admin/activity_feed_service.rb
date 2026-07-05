# frozen_string_literal: true

module Admin
  class ActivityFeedService
    VALID_TYPES = %w[expense_added expense_updated expense_deleted
                     settlement_made added_to_group removed_from_group
                     group_invitation payment_reminder].freeze

    def initialize(type: nil, from: nil, to: nil)
      @type = VALID_TYPES.include?(type.to_s) ? type : nil
      @from = from.present? ? Date.parse(from.to_s) : 30.days.ago.to_date
      @to   = to.present?   ? Date.parse(to.to_s)   : Date.current
    end

    def call
      scope = Notification.includes(:actor, :notifiable)
                          .where(created_at: @from.beginning_of_day..@to.end_of_day)
                          .order(created_at: :desc)
                          .limit(200)

      scope = scope.where(notification_type: @type) if @type

      scope.map do |n|
        {
          id:         n.id,
          type:       n.notification_type,
          title:      n.title,
          actor:      n.actor&.username || "System",
          notifiable: n.notifiable_type,
          occurred_at: n.created_at
        }
      end
    end
  end
end
