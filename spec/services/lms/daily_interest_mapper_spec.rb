require "rails_helper"

module Lms
  describe DailyInterestMapper do
    it "gives daily interest rate for a monthly period loan" do
      start_date = DateTime.strptime("2020-03-01", "%Y-%m-%y")

      loan = Loan.create({
        amount: 100000,
        interest: 0.01,
        period_cound: 2,
        start_date: start_date,
      })

      described_class.new(loan).execute
      binding.pry
    end
  end
end
