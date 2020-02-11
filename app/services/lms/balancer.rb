module Lms
  class Balancer
    attr_accessor :loan, :current_date

    def initialize(loan, current_date)
      @loan = loan
      @current_date = current_date
    end

    def execute
      sequence_logic = SequenceLogicBuilder.new(loan, current_date).execute
      initial_repayment_dates = loan.initial_repayment_dates
      date_of_balance = loan.date_of_balance
      return unless date_of_balance
      balancing_logic = BalancingLogic.new(sequence_logic, initial_repayment_dates, date_of_balance, current_date)
      adjustments, result = balancing_logic.execute
      sequence_logic = balancing_logic.sequence_logic
      table = sequence_logic.execute

      case result
      when Loan::LATE
        interest = loan.expected_transactions.pluck(:amount).sum + adjustments[:new_balance]
        loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST_FEE, date: current_date, amount: -1*interest, note: "Late payment - #{current_date}") if interest.round(2) != 0
      end

      [table, result]
    end
  end
end
