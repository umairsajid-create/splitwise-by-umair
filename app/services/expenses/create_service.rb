# frozen_string_literal: true

module Expenses
  class CreateService
    def initialize(group:, creator:, params:, split_data:)
      @group      = group
      @creator    = creator
      @params     = params
      @split_data = split_data  # Array of { user_id:, owed_amount_cents: }
    end

    def call
      expense = @group.expenses.build(
        @params.merge(created_by: @creator)
      )

      Expense.transaction do
        expense.save!
        create_splits(expense)
        recalculate_balances
        create_notifications(expense)
      end

      expense
    rescue ActiveRecord::RecordInvalid => e
      expense.errors.add(:base, e.message)
      expense
    end

    private

    def create_splits(expense)
      payer_id = @params[:paid_by_id].to_i

      @split_data.each do |split|
        user_id = split[:user_id].to_i
        owed    = split[:owed_amount_cents].to_i
        paid    = user_id == payer_id ? expense.total_amount_cents : 0

        expense.expense_splits.create!(
          user_id:            user_id,
          paid_amount_cents:  paid,
          owed_amount_cents:  owed
        )
      end
    end

    def recalculate_balances
      user_ids = @split_data.map { |s| s[:user_id].to_i }.uniq
      User.where(id: user_ids).each do |user|
        Balances::RecalculateService.new(user).call
      end
    end

    def create_notifications(expense)
      notification = Notification.create!(
        actor:             @creator,
        notifiable:        expense,
        notification_type: :expense_added,
        title:             "New expense in #{@group.name}",
        body:              "#{@creator.username} added \"#{expense.title}\""
      )

      # Recipients: all members of the group except the actor
      recipients = @group.members.where.not(id: @creator.id)
      recipients.each do |recipient|
        notification.notification_recipients.create!(recipient: recipient)
      end
    end
  end
end
