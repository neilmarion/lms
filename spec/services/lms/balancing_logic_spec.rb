require "rails_helper"

module Lms
  describe BalancingLogic do
    let(:daily_interest_map) {
      {
       "2020-03-01"=>0.0003125,
       "2020-03-02"=>0.0003125,
       "2020-03-03"=>0.0003125,
       "2020-03-04"=>0.0003125,
       "2020-03-05"=>0.0003125,
       "2020-03-06"=>0.0003125,
       "2020-03-07"=>0.0003125,
       "2020-03-08"=>0.0003125,
       "2020-03-09"=>0.0003125,
       "2020-03-10"=>0.0003125, "2020-03-11"=>0.0003125,
       "2020-03-12"=>0.0003125,
       "2020-03-13"=>0.0003125,
       "2020-03-14"=>0.0003125,
       "2020-03-15"=>0.0003125,
       "2020-03-16"=>0.0003125,
       "2020-03-17"=>0.0003125,
       "2020-03-18"=>0.0003125,
       "2020-03-19"=>0.0003125,
       "2020-03-20"=>0.0003125,
       "2020-03-21"=>0.0003125,
       "2020-03-22"=>0.0003125,
       "2020-03-23"=>0.0003125,
       "2020-03-24"=>0.0003125,
       "2020-03-25"=>0.0003125,
       "2020-03-26"=>0.0003125,
       "2020-03-27"=>0.0003125,
       "2020-03-28"=>0.0003125,
       "2020-03-29"=>0.0003125,
       "2020-03-30"=>0.0003125,
       "2020-03-31"=>0.0003125,
       "2020-04-01"=>0.0003125,
       "2020-04-02"=>0.0003333333333333333,
       "2020-04-03"=>0.0003333333333333333,
       "2020-04-04"=>0.0003333333333333333,
       "2020-04-05"=>0.0003333333333333333,
       "2020-04-06"=>0.0003333333333333333,
       "2020-04-07"=>0.0003333333333333333,
       "2020-04-08"=>0.0003333333333333333,
       "2020-04-09"=>0.0003333333333333333,
       "2020-04-10"=>0.0003333333333333333,
       "2020-04-11"=>0.0003333333333333333,
       "2020-04-12"=>0.0003333333333333333,
       "2020-04-13"=>0.0003333333333333333,
       "2020-04-14"=>0.0003333333333333333,
       "2020-04-15"=>0.0003333333333333333,
       "2020-04-16"=>0.0003333333333333333,
       "2020-04-17"=>0.0003333333333333333,
       "2020-04-18"=>0.0003333333333333333,
       "2020-04-19"=>0.0003333333333333333,
       "2020-04-20"=>0.0003333333333333333,
       "2020-04-21"=>0.0003333333333333333,
       "2020-04-22"=>0.0003333333333333333,
       "2020-04-23"=>0.0003333333333333333,
       "2020-04-24"=>0.0003333333333333333,
       "2020-04-25"=>0.0003333333333333333,
       "2020-04-26"=>0.0003333333333333333,
       "2020-04-27"=>0.0003333333333333333,
       "2020-04-28"=>0.0003333333333333333,
       "2020-04-29"=>0.0003333333333333333,
       "2020-04-30"=>0.0003333333333333333,
       "2020-05-01"=>0.0003333333333333333,
       "2020-05-02"=>0.0003333333333333333
      }
    }

    let(:base_payments) do
      {
        "2020-04-01"=>50751.24378109451,
        "2020-05-01"=>50751.24378109451,
      }
    end

    let(:date_of_balance) { "2020-05-01" }
    let(:amount) { 100000 }
    let(:sequence_logic) do
      SequenceLogic.new(amount, daily_interest_map, transactions)
    end

    context "customer paid late" do
      let(:remaining_balance) do
        base_payments.values.sum
      end
      let(:current_date) { "2020-04-06" }
      let(:transactions) do
        [
          { date: "2020-05-01", amount: -50751.24378109451 },
        ]
      end
      let(:expected_result) do
        #{ interest: -83.61063173724688, date: "2020-04-06" }
        # NOTE: remaining_balance + new_balance in order to get -83.61063173724688
        { new_balance: -101586.09819392627 }
      end

      specify do
        logic = described_class.new(sequence_logic, base_payments.keys, date_of_balance, current_date)
        result, state = logic.execute
        expect(state).to eq Loan::LATE
        expect(result).to eq expected_result
      end
    end

    context "customer paid early" do
      let(:current_date) { "2020-03-20" }
      let(:transactions) do
        [
          { date: "2020-03-20", amount: -60000 },
          { date: "2020-04-01", amount: -50751.24378109451 },
          { date: "2020-05-01", amount: -50751.24378109451 },
        ]
      end

      specify do
        logic = described_class.new(sequence_logic, base_payments.keys, date_of_balance, current_date)
        table, state = logic.execute
        expect(state).to eq Loan::EARLY
        # NOTE: This should be the new values of the expected repayments
        expect(table["2020-04-01"][:pri_chg]).to eq -40625.0
        expect(table["2020-04-01"][:int_chg]).to eq -152.34375
        expect(table["2020-05-01"][:pri_chg]).to eq 0
        expect(table["2020-05-01"][:int_chg]).to eq 0
      end
    end
  end
end
