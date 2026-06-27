# frozen_string_literal: true

FactoryBot.define do
  factory :default_split do
    association :user
    association :group
    name { "#{Faker::Food.dish} split" }
    split_type { :equal }
    split_config { { splits: [ { user_id: 1, percentage: 50 }, { user_id: 2, percentage: 50 } ] } }
  end
end
