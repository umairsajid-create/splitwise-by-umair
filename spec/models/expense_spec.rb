# frozen_string_literal: true

require "rails_helper"

RSpec.describe Expense, type: :model do
  describe "associations" do
    it { should belong_to(:group) }
    it { should belong_to(:created_by).class_name("User") }
    it { should have_many(:expense_splits).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:total_amount_cents) }
    it { should validate_numericality_of(:total_amount_cents).is_greater_than(0) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:expense_date) }
  end

  describe "enums" do
    it { should define_enum_for(:record_type).with_values(expense: 0, settlement: 1).without_instance_methods }
    it { should define_enum_for(:split_type).with_values(equal: 0, exact: 1, percentage: 2, adjustment: 3) }
    it { should define_enum_for(:status).with_values(active: 0, deleted: 1, updated: 2) }

    it "does not define record_type predicate methods (avoids conflicts on reload)" do
      expect(Expense.instance_methods).not_to include(:expense?)
      expect(Expense.instance_methods).not_to include(:record_type_expense?)
    end
  end

  describe "#settlement?" do
    it "returns true for settlement record type" do
      expect(build(:expense, :settlement).settlement?).to be true
    end

    it "returns false for expense record type" do
      expect(build(:expense).settlement?).to be false
    end
  end

  describe "scopes" do
    let!(:expense) { create(:expense) }
    let!(:settlement) { create(:expense, :settlement) }
    let!(:deleted_expense) { create(:expense, :deleted) }

    it "returns only expenses" do
      expect(Expense.expenses_only).to include(expense)
      expect(Expense.expenses_only).not_to include(settlement)
    end

    it "returns only settlements" do
      expect(Expense.settlements_only).to include(settlement)
      expect(Expense.settlements_only).not_to include(expense)
    end

    it "returns only active records" do
      expect(Expense.active_records).to include(expense)
      expect(Expense.active_records).not_to include(deleted_expense)
    end
  end

  describe "#total_amount" do
    it "converts cents to decimal" do
      expense = build(:expense, total_amount_cents: 2550)
      expect(expense.total_amount).to eq(25.50)
    end
  end

  describe "#soft_delete!" do
    it "sets status to deleted" do
      expense = create(:expense)
      expense.soft_delete!
      expect(expense.reload.status).to eq("deleted")
    end
  end
end
