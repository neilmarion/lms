module Lms
  class LoanStateBuilder
    attr_accessor :loan

    def initialize
      @loan = loan
    end

    private

    def unrealized_expected_payments
      loan.expected_transactions.where("date > ?", loan.events.last.date)
    end

    def daily_interest_map
      DailyInterestMapper
    end
  end
end
