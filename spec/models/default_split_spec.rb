# frozen_string_literal: true

require "rails_helper"

RSpec.describe DefaultSplit, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:group) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should validate_presence_of(:split_type) }
    it { should validate_presence_of(:split_config) }
  end

  describe "enums" do
    it { should define_enum_for(:split_type).with_values(equal: 0, exact: 1, percentage: 2, adjustment: 3) }
  end
end
