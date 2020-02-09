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
        total_principal_adjustment = 0
        total_interest_adjustment = 0

        initial_repayment_dates.select{ |x| x >= current_date }.each do |date|
          principal_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_PRINCIPAL, ExpectedTransaction::PRINCIPAL]).pluck(:amount).sum
          principal_adjustment = (principal_sum + adjustments[date.to_s][:pri_chg])
          total_principal_adjustment = total_principal_adjustment + principal_adjustment
          loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: date, amount: -1*principal_adjustment) if principal_adjustment != 0

          interest_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_INTEREST, ExpectedTransaction::INTEREST]).pluck(:amount).sum
          interest_adjustment = (interest_sum + adjustments[date.to_s][:int_chg])
          total_interest_adjustment = total_interest_adjustment + interest_adjustment
          loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: date, amount: -1*interest_adjustment, note: "Early payment adj - #{current_date}") if interest_adjustment != 0
        end

        loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: current_date, amount: total_principal_adjustment) if total_principal_adjustment != 0
        loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: current_date, amount: total_interest_adjustment) if total_interest_adjustment != 0
      end

      [table, result]
    end
  end
end
