# frozen_string_literal: true

FactoryBot.define do
  factory :expense_split do
    association :expense
    association :user
    owed_amount_cents { 1000 }
    paid_amount_cents { 0 }
  end
end
