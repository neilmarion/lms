module Lms
  class CalculateLoanExpectedPaymentDates
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      dates = []
      period_start_date = loan.start_date

      loan.period_count.times do
        dates << period_start_date.strftime(DailyInterestMapper::DATE_ID_FORMAT)

        period_start_date = period_start_date.next_month
      end

      dates
    end
  end
end
