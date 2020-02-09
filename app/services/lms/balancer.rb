module Lms
  class Balancer
    attr_accessor :loan, :current_date

    def initialize(loan, current_date)
      @loan = loan
      @current_date = current_date
    end

    def execute
      sequence_logic = LoanStateBuilder.new(loan, current_date).execute
      initial_repayment_dates = loan.initial_repayment_dates
      date_of_balance = loan.date_of_balance
      balancing_logic = BalancingLogic.new(sequence_logic, initial_repayment_dates, date_of_balance, current_date)
      adjustments, result = balancing_logic.execute
      sequence_logic = balancing_logic.sequence_logic
      table = sequence_logic.execute

      case result
      when Loan::LATE
        interest = loan.expected_transactions_sum + adjustments[:new_balance]
        loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: current_date, amount: -1*interest, note: "Late payment - #{current_date}") if interest.round(2) != 0
      when Loan::EARLY
        initial_repayment_dates.select{ |x| x >= current_date }.each do |date|
          amount = adjustments.select{ |x| x[:date] == date }.map{ |x| x[:amount] }.sum
          principal_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_PRINCIPAL, ExpectedTransaction::PRINCIPAL]).pluck(:amount).sum
          interest_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_INTEREST, ExpectedTransaction::INTEREST]).pluck(:amount).sum

          loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: date, amount: -1*interest_sum, note: "int Early payment adj - #{current_date}")
          loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: date, amount: -1*principal_sum, note: "pri Early payment adj - #{current_date}")
          loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: current_date, amount: principal_sum, note: "pri Early payment adj - #{current_date}")
        end

        loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: current_date, amount: -table[current_date.to_s][:int_chg], note: "pri Early payment adj - #{current_date}")
      end

      [table, result]
    end
  end
end
