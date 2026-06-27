# frozen_string_literal: true

FactoryBot.define do
  factory :expense do
    association :group
    association :created_by, factory: :user
    record_type { :expense }
    category { :food }
    title { Faker::Commerce.product_name }
    total_amount_cents { Faker::Number.between(from: 100, to: 100_000) }
    currency { "PKR" }
    split_type { :equal }
    expense_date { Date.current }
    status { :active }

    trait :settlement do
      record_type { :settlement }
      category { :general }
      title { "Settlement" }
    end

    trait :deleted do
      status { :deleted }
    end
  end
end
