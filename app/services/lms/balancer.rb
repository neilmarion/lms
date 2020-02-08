module Lms
  class Balancer
    attr_accessor :loan, :current_date

    def initialize(loan, current_date)
      @loan = loan
      @current_date = current_date
    end

    def execute
      amortization_logic = LoanStateBuilder.new(loan, current_date).execute
      initial_repayment_dates = loan.initial_repayment_dates
      date_of_balance = loan.date_of_balance
      balancing_logic = BalancingLogic.new(amortization_logic, initial_repayment_dates, date_of_balance, current_date)
      adjustments, result = balancing_logic.execute

      case result
      when "late"
        interest = loan.balance + adjustments[:new_balance]
        loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: current_date, amount: -1*interest)
      when "early"
        initial_repayment_dates.select{ |x| x > current_date }.each do |date|
          principal_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_PRINCIPAL, ExpectedTransaction::PRINCIPAL]).pluck(:amount).sum
          principal_adjustment = (principal_sum + adjustments[date.to_s][:pri_chg])
          loan.expected_transactions.create(kind: ExpectedTransaction::PRINCIPAL, date: date, amount: -1*principal_adjustment)

          interest_sum = loan.expected_transactions.where(date: date, kind: [ExpectedTransaction::INIT_INTEREST, ExpectedTransaction::INTEREST]).pluck(:amount).sum
          interest_adjustment = (interest_sum + adjustments[date.to_s][:int_chg])
          loan.expected_transactions.create(kind: ExpectedTransaction::INTEREST, date: date, amount: -1*interest_adjustment)
        end
      end
    end
  end
end
