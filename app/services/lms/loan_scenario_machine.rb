module Lms
  class LoanScenarioMachine
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
      # zzz_int = ending interest
      # zzz_pri = ending principal
      # zzz_bal = ending balance
      #

      {
        date: "-",
        aaa_bal: nil,
        aaa_int: nil,
        aaa_pri: nil,
        day_int: nil,
        tot_int: nil,
        tot_chg: nil,
        int_chg: nil,
        pri_chg: nil,
        zzz_int: nil,
        zzz_pri: nil
        zzz_bal: loan.amount,
      }

      loan.interest_map.map do |row|
        {
          date: "-",
          aaa_bal: nil,
          aaa_int: nil,
          aaa_pri: nil,
          day_int: nil,
          tot_int: nil,
          tot_chg: nil,
          int_chg: nil,
          pri_chg: nil,
          zzz_int: nil,
          zzz_pri: nil
          zzz_bal: loan.amount,
        }
      end
    end
  end
end
