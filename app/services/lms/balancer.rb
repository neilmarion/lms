module Lms
  class Balancer
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      amortization_logic = LoanStateBuilder.new(loan, Date.today)
      adjustments = BalancingLogic.new()
    end
  end
end
