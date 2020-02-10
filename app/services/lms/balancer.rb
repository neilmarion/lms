module Lms
  class Balancer
    attr_accessor :loan, :current_date

    def initialize(loan, current_date)
      @loan = loan
      @current_date = current_date
    end

    def execute
      sequence_logic = SequenceLogicBuilder.new(loan, current_date, SequenceLogicBuilder::FOR_BALANCING).execute
      initial_repayment_dates = loan.initial_repayment_dates
      date_of_balance = loan.date_of_balance
      balancing_logic = BalancingLogic.new(sequence_logic, initial_repayment_dates, date_of_balance, current_date)
      adjustments, result = balancing_logic.execute
      sequence_logic = balancing_logic.sequence_logic
      table = sequence_logic.execute

      case result
      when Loan::LATE
        interest = loan.expected_transactions_sum + loan.expected_transactions.where(kind: ExpectedTransaction::INTEREST_FEE).pluck(:amount).sum + adjustments[:new_balance]
        loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST_FEE, date: current_date, amount: -1*interest, note: "Late payment - #{current_date}") if interest.round(2) != 0
      when Loan::EARLY
        initial_repayment_dates.select{ |x| x > current_date }.each do |date|
          principal_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_PRINCIPAL, ExpectedTransaction::PRINCIPAL]).pluck(:amount).sum
          interest_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_INTEREST, ExpectedTransaction::INTEREST]).pluck(:amount).sum

          new_interest = -1*adjustments[date.to_s][:int_chg]
          new_principal = -1*adjustments[date.to_s][:pri_chg]

          loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: date, amount: interest_sum - (interest_sum - new_interest), note: "int Early payment adj - #{current_date}")
          loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: date, amount: principal_sum - (principal_sum - new_principal), note: "pri Early payment adj - #{current_date}")
          loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: current_date, amount: principal_sum - new_principal, note: "pri Early payment adj - #{current_date}")

          loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: date, amount: -interest_sum, note: "int Early payment adj - #{current_date}")
          loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: date, amount: -principal_sum, note: "pri Early payment adj - #{current_date}")
        end
      end

      [table, result]
    end
  end
end
