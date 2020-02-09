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

    describe "scenarios" do
      context "when loan is paid on time" do
        specify do
          current_date = "2020-03-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          expect(loan.remaining_balance).to eq 101502.48756218905
          expect(loan.remaining_interest).to eq 1502.487562189055
          expect(loan.remaining_principal).to eq 100000.00
          expect(loan.paid_balance).to eq 0.0
          expect(loan.paid_interest).to eq 0.0
          expect(loan.paid_principal).to eq 0.0
          expect(loan.status).to eq Loan::ONTIME

          # Customer pays on time
          current_date = "2020-04-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          actual_transaction = loan.actual_transactions.create({
            amount: -1*loan.expected_payment_per_period,
            created_at: current_date,
            updated_at: current_date,
          })
          binding.pry
          expect(loan.remaining_balance).to eq 50751.243781094556
          expect(loan.remaining_interest).to eq 502.4875621890551
          expect(loan.remaining_principal).to eq 50248.7562189055
          expect(loan.paid_balance).to eq -50751.2437810945
          expect(loan.paid_interest).to eq -1000.00
          expect(loan.paid_principal).to eq -49751.2437810945
          expect(loan.status).to eq Loan::ONTIME
        end
      end
    end
  end
end
