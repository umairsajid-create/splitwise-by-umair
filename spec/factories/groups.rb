# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    association :creator, factory: :user
    name { Faker::Team.name }
    group_type { :home }
    is_active { true }

    trait :trip do
      group_type { :trip }
    end

    trait :archived do
      is_active { false }
    end
  end
end
