module Lms
  class LoanScenarioMachine3
    attr_accessor :loan, :adjustment_events

    def initialize(loan, adjustment_events)
      @loan = loan
      @adjustment_events = adjustment_events
    end

    def execute()
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

      start_date = (loan.start_date).strftime(DailyInterestMapper::DATE_ID_FORMAT)
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
        custom_payment: nil,
        past: nil,
      }

      loan.daily_interest_map.map do |date, int|
        aaa_bal = temp[:zzz_bal]
        aaa_pri = temp[:zzz_pri]
        day_int = temp[:zzz_pri] * int
        tot_int = temp[:zzz_int] + day_int
        tot_chg = sum_of_changes(date)
        int_chg = 0
        pri_chg = 0

        int_chg, pri_chg = calculate_events(tot_chg, tot_int)

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
          expected: nil,
          custom_payment: nil,
          past: nil,
        }

        temp
      end.unshift(first)
    end

    def calculate_events(tot_chg, tot_int)
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

      return int_chg, pri_chg
    end

    def sum_of_changes(date)
      amounts = loan.actual_events.where(date: date, name: ["change"]).pluck(:data)
      actual_events_sum = amounts.inject(0){ |sum, tuple| sum += tuple["amount"] }

      expected_payment = if date > loan.actual_events.last.date
        loan.expected_payments[date].to_f
      end

      adjustment_events_sum = adjustment_events.select{ |ae| ae[:date] == date }.map{ |ae| ae[:amount] }.sum
      actual_events_sum + adjustment_events_sum + (-1*expected_payment.to_f)
    end

    def events_summary(date)
      events = loan.actual_events.where(date: date, name: ["change"]).pluck(:data)
      events.map do |e|
        if e["amount"] >= 0
          "Topped up #{e["amount"]}"
        else
          "Paid #{-1*e["amount"]}"
        end
      end.join("; ")
    end
  end
end
