# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    association :user
    plan { :monthly }
    status { :active }
    amount_cents { 99900 }
    currency { "PKR" }
    payment_method { :credit_card }
    starts_at { Time.current }
    ends_at { 30.days.from_now }

    trait :yearly do
      plan { :yearly }
      amount_cents { 999900 }
      ends_at { 1.year.from_now }
    end

    trait :expired do
      status { :expired }
      ends_at { 1.day.ago }
    end
  end
end
