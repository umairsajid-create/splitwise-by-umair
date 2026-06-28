# frozen_string_literal: true

module Settlements
  class CreateService
    def initialize(group:, payer:, receiver:, amount_cents:, currency:)
      @group        = group
      @payer        = payer
      @receiver     = receiver
      @amount_cents = amount_cents
      @currency     = currency
    end

    def call
      settlement = nil

      Expense.transaction do
        settlement = @group.expenses.create!(
          created_by:         @payer,
          paid_by:            @payer,
          record_type:        :settlement,
          category:           :general,
          title:              "Settlement: #{@payer.username} → #{@receiver.username}",
          total_amount_cents: @amount_cents,
          currency:           @currency,
          split_type:         :exact,
          expense_date:       Date.today,
          status:             :active
        )

        # Payer's split: paid full, owes nothing
        settlement.expense_splits.create!(
          user:               @payer,
          paid_amount_cents:  @amount_cents,
          owed_amount_cents:  0
        )

        # Receiver's split: paid nothing, owes the amount (debt is recorded)
        settlement.expense_splits.create!(
          user:               @receiver,
          paid_amount_cents:  0,
          owed_amount_cents:  @amount_cents
        )

        # Recalculate both users' balances
        Balances::RecalculateService.new(@payer).call
        Balances::RecalculateService.new(@receiver).call
      end

      settlement
    end
  end
end
