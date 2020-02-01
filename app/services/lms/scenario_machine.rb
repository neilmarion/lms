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
      # cint = cumulative interest
      # tpay = total payment made
      # pded = principal deducted
      # ided = interest deducted
      # ebal = ending balance
      # eprn = ending principal
      # eint = ending interest
      loan.actual_events.all.map.with_index do |event, i|
      end
    end

    def get_day_count(start_date, end_date)
      (DateTime.strptime("2020-03-31", "%Y-%m-%d") - Date.today).to_i
    end
  end
end
