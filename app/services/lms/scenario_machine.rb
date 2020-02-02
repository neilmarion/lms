module Lms
  class ScenarioMachine
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      build_scenario
    end

    private

    def build_scenario(config)
      # date
      # aaa_bal = beginning balance
      # aaa_int = beginning interest
      # aaa_pri = beginning principal
      #
      # day_int = daily interest accrued
      # tot_int = total interest accrued
      #
      # tot_chg = total change (negative for payment, positive for to principal)
      # int_chg = interest change
      # pri_chg = principal change
      #
      # zzz_bal = ending balance
      # zzz_int = ending interest
      # zzz_pri = ending principal
      #
      #


    end
  end
end
