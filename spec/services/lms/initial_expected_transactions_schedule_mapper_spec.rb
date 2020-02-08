require "rails_helper"

module Lms
  describe InitialExpectedTransactionsScheduleMapper do
    let(:expected_result) {
      {
        "2020-04-01" => {
          interest: 1000.0,
          principal: 49751.24378109451,
        },
        "2020-05-01" => {
          interest: 502.4875621890549,
          principal: 50248.75621890546,
        },
      }

    }

    it "gives the initial expected payments given a loan" do
      start_date = DateTime.strptime("2020-03-01", "%Y-%m-%d")

      loan = Loan.create({
        amount: 100000,
        interest: 0.01,
        period_count: 2,
        start_date: start_date,
        period: "monthly",
      })

      result = described_class.new(loan).execute
      expect(result).to eq expected_result
    end
  end
end
