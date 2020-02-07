require "rails_helper"

module Lms
  describe InitialExpectedPaymentsMapper do
    let(:expected_result) {
      {
        "2020-04-01"=>50751.24378109451,
        "2020-05-01"=>50751.24378109451,
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
      expect(expected_result).to eq result
    end
  end
end
