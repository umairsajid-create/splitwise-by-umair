# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpenseSplit, type: :model do
  describe "associations" do
    it { should belong_to(:expense) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:expense_split) }

    it { should validate_presence_of(:owed_amount_cents) }
    it { should validate_numericality_of(:owed_amount_cents).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:paid_amount_cents) }
    it { should validate_numericality_of(:paid_amount_cents).is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:expense_id).with_message("already has a split for this expense") }
  end

  describe "#net_balance_cents" do
    it "returns positive when user paid more than owed" do
      split = build(:expense_split, paid_amount_cents: 5000, owed_amount_cents: 2500)
      expect(split.net_balance_cents).to eq(2500)
    end

    it "returns negative when user owes more than paid" do
      split = build(:expense_split, paid_amount_cents: 0, owed_amount_cents: 2500)
      expect(split.net_balance_cents).to eq(-2500)
    end

    it "returns zero when balanced" do
      split = build(:expense_split, paid_amount_cents: 2500, owed_amount_cents: 2500)
      expect(split.net_balance_cents).to eq(0)
    end
  end
end
