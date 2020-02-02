module Lms
  class LoanScenarioMachine
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute(scenario)
      build_scenario(scenario)
    end

    private

    def build_scenario(scenario)
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

      start_date = loan.start_date.strftime(DailyInterestMapper::DATE_ID_FORMAT)
      first = temp = {
        date: start_date,
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
        events_summary: nil,
        expected: nil,
      }

      # Remove scheduled repayments if they
      # are supposed to be overriden by actual events
      expected_payments = loan.expected_payments
      event_dates = loan.actual_events.pluck(:date).sort
      expected_payments.keys.each do |date|
        if event_dates.last && DateTime.parse(date) <= DateTime.parse(event_dates.last)
          expected_payments.delete(date)
        end
      end

      loan.daily_interest_map.map do |date, int|
        aaa_bal = temp[:zzz_bal]
        aaa_pri = temp[:zzz_pri]
        day_int = temp[:zzz_pri] * int
        tot_int = temp[:zzz_int] + day_int
        tot_chg = sum_of_changes(date, expected_payments, scenario)
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
          events_summary: events_summary(date),
          expected: expected_payment(expected_payments, date),
        }

        temp
      end.unshift(first)
    end

    def sum_of_changes(date, expected_payments, scenario)
      amounts = loan.actual_events.where(date: date, name: "change").pluck(:data)
      events_changes = amounts.inject(0){ |sum, tuple| sum += tuple["amount"] }

      if events_changes != 0
        events_changes
      else
        if scenario == "actual_and_expected"
          return (expected_payments[date] || 0)*-1
        else
          return 0
        end
      end
    end

    def events_summary(date)
      events = loan.actual_events.where(date: date, name: "change").pluck(:data)
      events.map do |e|
        if e["amount"] >= 0
          "Topped up #{e["amount"]}"
        else
          "Paid #{-1*e["amount"]}"
        end
      end.join("; ")
    end

    def expected_payment(expected_payments, date)
      if expected_payment = expected_payments[date]
        {
          expected_tot_payment: expected_payment,
        }
      end
    end
  end
end
