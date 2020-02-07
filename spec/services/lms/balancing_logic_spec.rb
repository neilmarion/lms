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
       "2020-03-10"=>0.0003125,
       "2020-03-11"=>0.0003125,
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
    let(:amortization_logic) do
      AmortizationLogic.new(amount, daily_interest_map, events)
    end

    context "customer paid late" do
      let(:last_event_date) { "2020-04-06" }
      let(:events) do
        [
          { date: last_event_date, amount: -50751.24378109451 },
          { date: "2020-05-01", amount: -50751.24378109451 },
        ]
      end
      let(:expected_result) do
        [
          { date: "2020-04-06", amount: -83.61091964942898 },
        ]
      end

      specify do
        logic = described_class.new(amortization_logic, base_payments, date_of_balance, last_event_date)
        result = logic.execute
        expect(expected_result).to eq result
      end
    end

    context "customer paid early" do
      let(:last_event_date) { "2020-03-20" }
      let(:events) do
        [
          { date: last_event_date, amount: -60000 },
          { date: "2020-04-01", amount: -50751.24378109451 },
          { date: "2020-05-01", amount: -50751.24378109451 },
        ]
      end
      let(:expected_result) do
        [
          { date: "2020-04-01", amount: 9973.900031094512 },
          { date: "2020-05-01", amount: 50751.24378109451 },
        ]
      end

      specify do
        logic = described_class.new(amortization_logic, base_payments, date_of_balance, last_event_date)
        result = logic.execute
      end
    end
  end
end
