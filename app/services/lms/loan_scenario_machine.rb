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

    def build_scenario
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

      first = temp = {
        date: loan.start_date.strftime(DailyInterestMapper::DATE_ID_FORMAT),
        aaa_bal: 0,
        aaa_pri: 0,
        day_int: 0,
        tot_int: 0,
        tot_chg: 0,
        int_chg: 0,
        pri_chg: 0,
        zzz_int: 0,
        zzz_pri: loan.amount,
        zzz_bal: loan.amount,
      }

      loan.daily_interest_map.map do |date, int|
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
        zzz_pri = aaa_pri + pri_chg
        zzz_bal = aaa_bal + day_int + tot_chg

        temp = {
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

        temp
      end.unshift(first)
    end

    def sum_of_changes(date)
      amounts = loan.actual_events.where(date: date, name: "change").pluck(:data)
      amounts.inject(0){ |sum, tuple| sum += tuple["amount"] }
    end
  end
end
