module Lms
  class DailyExpectedPaymentMapper
    DATE_ID_FORMAT = "%Y-%m-%d"
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      case loan.period
      when "daily"
      when "weekly"
      when "monthly"
        create_daily_expected_payment_map_for_monthly
      when "quarterly"
      when "biannualy"
      when "annualy"
      end
    end

    private

    def create_daily_expected_payment_map_for_monthly
      map = {}
      period_start_date = loan.start_date

      loan.period_count.times do
        range = period_start_date.to_date..period_start_date.next_month.to_date
        daily_expected_payment = loan.expected_payment_per_period / (range.count - 1)

        range.map{ |date| date.strftime(DATE_ID_FORMAT) }.map.with_index do |day, i|
          map[day] = daily_expected_payment
        end

        period_start_date = period_start_date.next_month
      end

      map
    end
  end
end
