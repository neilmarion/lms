module Lms
  class Balancer
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      amortization_logic = LoanStateBuilder.new(loan, Date.today)
      initial_repayment_dates = loan.initial_repayment_dates
      date_of_balance = loan.date_of_balance
      adjustments = BalancingLogic.new(initial_repayment_dates, date_of_balance, amortization_logic)
    end
  end
end
