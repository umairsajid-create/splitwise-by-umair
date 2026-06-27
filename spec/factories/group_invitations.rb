# frozen_string_literal: true

FactoryBot.define do
  factory :group_invitation do
    association :group
    association :invited_by, factory: :user
    email { Faker::Internet.unique.email }
    status { :pending }
    expires_at { 7.days.from_now }
  end
end
