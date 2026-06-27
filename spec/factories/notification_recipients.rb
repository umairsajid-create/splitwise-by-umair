# frozen_string_literal: true

FactoryBot.define do
  factory :notification_recipient do
    association :notification
    association :recipient, factory: :user
    read_at { nil }

    trait :read do
      read_at { Time.current }
    end
  end
end
