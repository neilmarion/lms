require "rails_helper"

module Lms
  describe LoanStateBuilder do
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

    context "null state" do
      it "builds the loan state" do
        loan
        binding.pry
      end
    end
  end
end
