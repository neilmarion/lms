require "rails_helper"

module Lms
  describe DailyInterestMapper do
    let(:expected_result) {
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

    it "gives daily interest rate for a monthly period loan" do
      start_date = DateTime.strptime("2020-03-01", "%Y-%m-%d")
      result = described_class.new(start_date, 0.01, "monthly", 2, nil).execute
      expect(expected_result).to eq result
    end
  end
end
