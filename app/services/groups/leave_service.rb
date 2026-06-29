# frozen_string_literal: true

module Groups
  class LeaveService
    class Error < StandardError; end

    def initialize(group:, user:)
      @group = group
      @user  = user
    end

    def call
      membership = @group.group_members.find_by(user: @user)
      raise Error, "You are not a member of this group." unless membership

      balance_cents = member_balance_cents(@user)
      raise Error, balance_message(balance_cents) unless balance_cents.zero?

      if sole_admin_with_other_members?(membership)
        raise Error, "You cannot leave this group because you are the only admin. Promote another member to admin first."
      end

      GroupMember.transaction do
        membership.destroy!
        Balances::RecalculateService.new(@user).call
      end

      @group
    end

    def self.member_balance_cents(group, user)
      Groups::BalanceService.new(group).call
                             .find { |entry| entry[:user] == user }
                             &.dig(:balance_cents) || 0
    end

    private

    def member_balance_cents(user)
      self.class.member_balance_cents(@group, user)
    end

    def balance_message(balance_cents)
      amount   = format("%.2f", balance_cents.abs / 100.0)
      currency = @user.default_currency.presence || "PKR"

      if balance_cents.positive?
        "You cannot leave this group. Other members still owe you #{currency} #{amount}. Please settle up first."
      else
        "You cannot leave this group. You still owe #{currency} #{amount} to other members. Please settle up first."
      end
    end

    def sole_admin_with_other_members?(membership)
      membership.admin? &&
        @group.group_members.admin.count == 1 &&
        @group.group_members.count > 1
    end
  end
end
