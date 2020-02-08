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

    let(:expected_result) do
      [{"kind"=>"init_interest", "amount"=>1000.0, "date"=>Date.parse("2020-04-01"), "loan_id"=>loan.id},
       {"kind"=>"init_principal", "amount"=>49751.2437810945, "date"=>Date.parse("2020-04-01"), "loan_id"=>loan.id},
       {"kind"=>"init_interest", "amount"=>502.487562189055, "date"=>Date.parse("2020-05-01"), "loan_id"=>loan.id},
       {"kind"=>"init_principal", "amount"=>50248.7562189055, "date"=>Date.parse("2020-05-01"), "loan_id"=>loan.id}]
    end

    it "creates the first expected payments after creation" do
      result = loan.expected_transactions.as_json.map do |x|
        x.delete("id")
        x.delete("created_at")
        x.delete("updated_at")
        x.delete("note")
        x
      end

      expect(result).to eq expected_result
    end
  end
end
