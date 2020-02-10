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
          expect(loan.remaining_balance.round(2)).to eq 101502.49
          expect(loan.remaining_interest.round(2)).to eq 1502.49
          expect(loan.remaining_principal.round(2)).to eq 100000.00
          expect(loan.paid_balance.round(2)).to eq 0.0
          expect(loan.paid_interest.round(2)).to eq 0.0
          expect(loan.paid_principal.round(2)).to eq 0.0
          expect(loan.status).to eq Loan::ONTIME

          # Customer pays on time on 2020-04-01
          current_date = "2020-04-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          actual_transaction = loan.actual_transactions.create({
            amount: -1*loan.expected_payment_per_period,
            created_at: current_date,
            updated_at: current_date,
          })
          expect(loan.remaining_balance.round(2)).to eq 50751.24
          expect(loan.remaining_interest.round(2)).to eq 502.49
          expect(loan.remaining_principal.round(2)).to eq 50248.76
          expect(loan.paid_balance.round(2)).to eq 50751.24
          expect(loan.paid_interest.round(2)).to eq 1000.00
          expect(loan.paid_principal.round(2)).to eq 49751.24
          expect(loan.status).to eq Loan::ONTIME

          # Customer pays on time on 2020-05-01
          current_date = "2020-05-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          actual_transaction = loan.actual_transactions.create({
            amount: -1*loan.expected_payment_per_period,
            created_at: current_date,
            updated_at: current_date,
          })
          expect(loan.remaining_balance.round(2)).to eq 0.0
          expect(loan.remaining_interest.round(2)).to eq 0.0
          expect(loan.remaining_principal.round(2)).to eq 0.0
          expect(loan.paid_balance.round(2)).to eq 101502.49
          expect(loan.paid_interest.round(2)).to eq 1502.49
          expect(loan.paid_principal.round(2)).to eq 100000.00
          expect(loan.status).to eq Loan::ONTIME
        end
      end
    end

    describe "scenarios" do
      context "when loan is paid early" do
        specify do
          current_date = "2020-03-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          expect(loan.remaining_balance.round(2)).to eq 101502.49
          expect(loan.remaining_interest.round(2)).to eq 1502.49
          expect(loan.remaining_principal.round(2)).to eq 100000.00
          expect(loan.paid_balance.round(2)).to eq 0.0
          expect(loan.paid_interest.round(2)).to eq 0.0
          expect(loan.paid_principal.round(2)).to eq 0.0
          expect(loan.status).to eq Loan::ONTIME

          # Customer pays on time on 2020-04-01
          current_date = "2020-04-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          actual_transaction = loan.actual_transactions.create({
            amount: -1*70000,
            created_at: current_date,
            updated_at: current_date,
          })

          expect(loan.paid_balance.round(2)).to eq 70000.0
          expect(loan.paid_interest.round(2)).to eq 1000.00
          expect(loan.paid_principal.round(2)).to eq 69000.0
          expect(loan.remaining_balance.round(2)).to eq 31310.0
          expect(loan.remaining_interest.round(2)).to eq 310.0
          expect(loan.remaining_principal.round(2)).to eq 31000.00
          expect(loan.reload.status).to eq Loan::EARLY

          current_date = "2020-05-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          actual_transaction = loan.actual_transactions.create({
            amount: -1*31310.0,
            created_at: current_date,
            updated_at: current_date,
          })
          expect(loan.remaining_balance).to eq 0.0
          expect(loan.remaining_interest).to eq 0.0
          expect(loan.remaining_principal).to eq 0.0
          expect(loan.paid_balance).to eq 101310.0
          expect(loan.paid_interest).to eq 1310.0
          expect(loan.paid_principal).to eq 100000.00
          expect(loan.reload.status).to eq Loan::ONTIME
        end
      end
    end

    describe "scenarios" do
      context "when loan is paid late" do
        specify do
          current_date = "2020-03-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          expect(loan.remaining_balance.round(2)).to eq 101502.49
          expect(loan.remaining_interest.round(2)).to eq 1502.49
          expect(loan.remaining_principal.round(2)).to eq 100000.00
          expect(loan.paid_balance.round(2)).to eq 0.0
          expect(loan.paid_interest.round(2)).to eq 0.0
          expect(loan.paid_principal.round(2)).to eq 0.0
          expect(loan.status).to eq Loan::ONTIME

          # Customer does not pay on 2020-04-01
          current_date = "2020-04-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          loan.do_balance
          current_date = "2020-04-02"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          loan.do_balance
          expect(loan.remaining_balance.round(2)).to eq 101519.23
          expect(loan.remaining_interest.round(2)).to eq 1519.23
          expect(loan.remaining_principal.round(2)).to eq 100000
          expect(loan.paid_balance.round(2)).to eq 0
          expect(loan.paid_interest.round(2)).to eq 0
          expect(loan.paid_principal.round(2)).to eq 0
          expect(loan.status).to eq Loan::LATE

          current_date = "2020-04-03"
          allow(Date).to receive(:today).and_return(current_date.to_date)
          loan.do_balance
          expect(loan.remaining_balance.round(2)).to eq 101535.96
          expect(loan.remaining_interest.round(2)).to eq 1535.96
          expect(loan.remaining_principal.round(2)).to eq 100000
          expect(loan.paid_balance.round(2)).to eq 0
          expect(loan.paid_interest.round(2)).to eq 0
          expect(loan.paid_principal.round(2)).to eq 0
          expect(loan.status).to eq Loan::LATE

          actual_transaction = loan.actual_transactions.create({
            amount: -1*(loan.expected_payment_per_period + loan.expected_transactions.where(kind: "interest_fee").pluck(:amount).sum.round(2)),
            created_at: current_date,
            updated_at: current_date,
          })

          expect(loan.remaining_balance.round(2)).to eq 50751.24
          expect(loan.remaining_interest.round(2)).to eq 469.3
          expect(loan.remaining_principal.round(2)).to eq 50281.94
          expect(loan.paid_balance.round(2)).to eq 50784.72
          expect(loan.paid_interest.round(2)).to eq 1066.67
          expect(loan.paid_principal.round(2)).to eq 49718.06
          expect(loan.reload.status).to eq Loan::ONTIME

          current_date = "2020-05-01"
          allow(Date).to receive(:today).and_return(current_date.to_date)

          actual_transaction = loan.actual_transactions.create({
            amount: -loan.expected_payment_per_period,
            created_at: current_date,
            updated_at: current_date,
          })


          expect(loan.remaining_balance.round(2)).to eq 0.0
          expect(loan.remaining_interest.round(2)).to eq 0.0
          expect(loan.remaining_principal.round(2)).to eq 0.0
          expect(loan.paid_balance.round(2)).to eq 101535.97
          expect(loan.paid_interest.round(2)).to eq 1535.96
          expect(loan.paid_principal.round(2)).to eq 100000.0
          expect(loan.reload.status).to eq Loan::ONTIME
        end
      end
    end
  end
end
