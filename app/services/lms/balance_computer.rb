module Lms
  class BalanceComputer
    attr_accessor :loan, :latest_event_date

    def initialize(loan)
      @loan = loan
    end

    def execute
      expected_payment_dates = Lms::Loan.last.expected_payments.keys
      date_of_balance = expected_payment_dates.last

      scenario = Lms::LoanScenarioMachine2.new(loan).execute

      row = find_row_by_date(scenario, date_of_balance)
      if row[:zzz_bal].round(2) < 0
        traverse_until_balanced_for_early_payment(expected_payment_dates, date_of_balance)
      elsif row[:zzz_bal].round(2) > 0
        date_to_manipulate = loan.actual_events.last.date
        traverse_until_balanced_for_late_payment(expected_payment_dates, date_of_balance, date_to_manipulate)
      end
    end

    private

    def find_row_by_date(scenario, date)
      scenario.find do |s|
        s[:date] == date
      end
    end

    def traverse_until_balanced_for_early_payment(expected_payment_dates, date_of_balance)
      adjustment_events = []
      scenario = Lms::LoanScenarioMachine3.new(loan, adjustment_events).execute

      loop do
        scenario.each do |row|
          if (expected_payment_dates.include? row[:date]) && (row[:zzz_bal].round(2) < 0)
            #loan.actual_events.create(data: {amount: row[:zzz_bal]*-1}, name: "bal_change", date: row[:date])
            adjustment_events << { date: row[:date], amount: row[:zzz_bal]*-1 }
            break
          end
        end

        scenario = Lms::LoanScenarioMachine3.new(loan, adjustment_events).execute

        break if find_row_by_date(scenario, date_of_balance)[:zzz_bal].round(2) == 0
      end

      [adjustment_events, "early"]
    end

    def traverse_until_balanced_for_late_payment(expected_payment_dates, date_of_balance, date_to_manipulate)
      adjustment_events = []
      scenario = Lms::LoanScenarioMachine3.new(loan, adjustment_events).execute

      loop do
        row_of_balance = find_row_by_date(scenario, date_of_balance)
        row_of_balance[:zzz_bal]
        adjustment_events << { date: date_to_manipulate, amount: row_of_balance[:zzz_bal]*-1 }
        #loan.actual_events.create(data: {amount: row_of_balance[:zzz_bal]*-1}, name: "bal_change", date: date_to_manipulate)

        scenario = Lms::LoanScenarioMachine3.new(loan, adjustment_events).execute

        if find_row_by_date(scenario, date_of_balance)[:zzz_bal].round(2) == 0
          break
        end
      end

      [adjustment_events, "late"]
    end
  end
end
