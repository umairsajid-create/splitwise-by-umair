# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :actor, factory: :user
    association :notifiable, factory: :expense
    notification_type { :expense_added }
    title { "New expense added" }
    body { Faker::Lorem.sentence }
  end
end
