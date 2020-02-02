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
      # aaa_pri = beginning principal
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

      temp = {
        date: "-",
        aaa_bal: nil,
        aaa_pri: nil,
        day_int: nil,
        tot_int: nil,
        tot_chg: nil,
        int_chg: nil,
        pri_chg: nil,
        zzz_int: 0,
        zzz_pri: loan.amount,
        zzz_bal: loan.amount,
      }

      loan.interest_map.map do |date, int|
        aaa_bal = temp[:zzz_bal]
        aaa_pri = temp[:zzz_pri]
        day_int = temp[:zzz_pri] * int
        tot_int = temp[:zzz_int] + day_int
        tot_chg = sum_of_changes(date)
        int_chg = 0
        pri_chg = 0

        # If tot_chg is negative, that means
        # the customer has paid some amount
        if tot_chg < 0
          # Pay off interest before principal
          if (tot_chg)*-1 >= tot_int
            int_chg = tot_int*-1
            pri_chg = tot_chg - int_chg
          else
            int_chg = tot_chg
          end
        # If tot_chg is positive, that means
        # the customer added principal
        elsif tot_chg > 0
          pri_chg = tot_chg
        end

        zzz_int = tot_int + int_chg
        zzz_pri = tot_pri + pri_chg
        zzz_bal = aaa_bal + day_int + tot_chg

        {
          date: date,
          aaa_bal: aaa_bal,
          aaa_pri: aaa_pri,
          day_int: day_int,
          tot_int: tot_int,
          tot_chg: tot_chg,
          int_chg: int_chg,
          pri_chg: pri_chg,
          zzz_int: zzz_int,
          zzz_pri: zzz_pri,
          zzz_bal: zzz_bal,
        }
      end

      def sum_of_changes(date)
        loan.events.where(date: date, name: "change").sum
      end
    end
  end
end
