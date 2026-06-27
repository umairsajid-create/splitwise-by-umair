# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    username { Faker::Internet.unique.username(specifier: 3..20) }
    phone_number { Faker::PhoneNumber.phone_number[0..19] }
    role { :simple }
    daily_expense_limit { 5 }
    daily_settlement_limit { 3 }
    default_currency { "PKR" }

    trait :premium do
      role { :premium }
      daily_expense_limit { 0 }
      daily_settlement_limit { 0 }
    end

    trait :admin do
      role { :admin }
      daily_expense_limit { 0 }
      daily_settlement_limit { 0 }
    end
  end
end
