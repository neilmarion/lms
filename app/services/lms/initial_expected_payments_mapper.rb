module Lms
  class InitialExpectedPaymentsMapper
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      expected_payments = {}
      period_due_date = loan.start_date.next_month

      loan.period_count.times do
        expected_payments[
          period_due_date.strftime(DailyInterestMapper::DATE_ID_FORMAT)
        ] = loan.expected_payment_per_period
        period_due_date = period_due_date.next_month
      end

      expected_payments
    end
  end
end
