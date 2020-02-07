require "rails_helper"

module Lms
  describe Loan do
    let(:start_date) { "2020-03-01" }
    let(:loan) do
      Loan.create({
        amount: 100000,
        interest: 0.01,
        period_count: 2,
        start_date: start_date,
        period: "monthly",
      })
    end

    it "calculates initial repayment schedule" do
      result = loan.initial_repayment_schedule
      expect(result).to eq ({"2020-04-01"=>50751.24378109451, "2020-05-01"=>50751.24378109451})
    end

    it "creates the first expected payments after creation" do
      result = loan.expected_payments.first
      expect(result.name).to eq "initial_balance"
      expect(result.amount).to eq 101502.487562189
    end
  end
end
