module Lms
  class InitialLoanExpectedPayments
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      expected_payments = {}
      period_start_date = loan.start_date

      loan.period_count.times do
        expected_payments[period_start_date.strftime(DailyInterestMapper::DATE_ID_FORMAT)] = loan.expected_payment_per_period
        period_start_date = period_start_date.next_month
      end

      expected_payments
    end
  end
end
