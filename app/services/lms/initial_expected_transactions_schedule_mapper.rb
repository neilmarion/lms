module Lms
  class InitialExpectedTransactionsScheduleMapper
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      initial_repayment_schedule = {}
      period_due_date = loan.start_date.next_month

      loan.period_count.times do
        initial_repayment_schedule[
          period_due_date.strftime(DailyInterestMapper::DATE_ID_FORMAT)
        ] = loan.expected_payment_per_period
        period_due_date = period_due_date.next_month
      end

      initial_repayment_schedule
    end
  end
end
