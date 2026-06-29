# frozen_string_literal: true

module Groups
  class DeleteService
    class Error < StandardError; end

    def initialize(group:)
      @group = group
    end

    def call
      unsettled = unsettled_balances
      raise Error, error_message(unsettled) if unsettled.any?

      members = @group.members.to_a
      group_name = @group.name

      Group.transaction do
        @group.destroy!
      end

      members.each { |user| Balances::RecalculateService.new(user).call }

      group_name
    end

    def self.unsettled_balances(group)
      Groups::BalanceService.new(group).call.reject { |entry| entry[:balance_cents].zero? }
    end

    private

    def unsettled_balances
      self.class.unsettled_balances(@group)
    end

    def error_message(unsettled)
      details = unsettled.map { |entry| member_balance_line(entry) }.join(" ")
      "Cannot delete this group until all balances are settled. #{details}"
    end

    # tell what user owes or what user is owed
    def member_balance_line(entry)
      user     = entry[:user]
      cents    = entry[:balance_cents]
      amount   = format("%.2f", cents.abs / 100.0)
      currency = user.default_currency.presence || "PKR"

      if cents.positive?
        "#{user.username} is owed #{currency} #{amount}."
      else
        "#{user.username} owes #{currency} #{amount}."
      end
    end
  end
end
