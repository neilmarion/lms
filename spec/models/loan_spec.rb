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

    it "creates the first expected payments after creation" do
      result = loan.expected_transactions.first
      expect(result.kind).to eq "initial_balance"
      expect(result.amount).to eq 101502.487562189
      expect(result.date.to_s).to eq "2020-04-01"

      result = loan.expected_transactions.last
      expect(result.kind).to eq "initial_balance"
      expect(result.amount).to eq 101502.487562189
      expect(result.date.to_s).to eq "2020-05-01"
    end
  end
end
