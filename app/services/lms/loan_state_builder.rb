module Lms
  class LoanStateBuilder
    attr_accessor :loan

    def initialize

    end

    private

    def unrealized_expected_payments
      loan.expected_payments
    end

    def latest_event

    end
  end
end
