# frozen_string_literal: true

FactoryBot.define do
  factory :group_member do
    association :group
    association :user
    invited_by { nil }
    role { :member }
    joined_at { Time.current }

    trait :admin do
      role { :admin }
    end
  end
end
