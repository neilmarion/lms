module Lms
  class ActualScenarioMachine
    attr_accessor :scenario

    def initialize(loan)
      @loan = loan
      scenario = [] # Array of Hashes
    end

    def execute
    end

    private

    def build_actual_plus_worst_case_scenario
      # bbal = beginning balance
      # bprn = beginning principal
      # dint = daily interest accrued
      # cint = cumulative interest
      # tpay = total payment made
      # pded = principal deducted
      # ided = interest deducted
      # ebal = ending balance
      # eprn = ending principal
      # eint = ending interest

      bbal = loan.amount
      bprn = loan.amount
      dint = bbal*loan.interest_per_day
      cint = dint

      cache = {
        date: day,
        bbal: bbal,
        bprn: bprn,
        dint: dint,
        cint: cint,
        tpay: 0,
        pded: 0,
        ided: 0,
        ebal: bbal,
        eprn: bbal,
        eint: dint,
      }

      (loan.start_date..Date.today).map{ |date| date.strftime("%Y-%m-%d") }.map.with_index do |day, i|
        events = loan.actual_events.where(date: day)
        events.each do |event|

        end
      end
    end

    def get_day_count(start_date, end_date)
      (DateTime.strptime("2020-03-31", "%Y-%m-%d") - Date.today).to_i
    end
  end
end
