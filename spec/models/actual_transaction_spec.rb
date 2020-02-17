require "rails_helper"

module Lms
  describe ActualTransaction do
    let(:start_date) { "2020-03-01" }
    let(:current_date) { "2020-04-01" }
    let(:loan) do
      Loan.create({
        amount: 100000,
        interest: 0.01,
        period_count: 2,
        start_date: start_date,
        period: "monthly",
      })
    end

    it "includes breakdown" do
      allow(Date).to receive(:today).and_return(current_date.to_date)
      actual_transaction = loan.actual_transactions.create({
        amount: -loan.expected_payment_per_period,
        created_at: current_date,
        updated_at: current_date,
      })
    end
  end
end
