require "rails_helper"

module Lms
  describe Loan do
    let(:start_date) { "2020-03-01" }

    it "calculates initial repayment schedule" do
      loan = Loan.create({
        amount: 100000,
        interest: 0.01,
        period_count: 2,
        start_date: start_date,
        period: "monthly",
      })

      result = loan.initial_repayment_schedule
      expect(result).to eq ({"2020-04-01"=>50751.24378109451, "2020-05-01"=>50751.24378109451})
    end
  end
end
