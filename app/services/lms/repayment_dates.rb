module Lms
  class RepaymentDates
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      return loan.repayment_dates.map(&:to_date) unless loan.repayment_dates.blank?

      case loan.period
      when "daily"
      when "every_three_days"
        initial_dates_for_every_three_days
      when "weekly"
      when "monthly"
        initial_dates_for_monthly
      when "quarterly"
      when "biannualy"
      when "annualy"
      end
    end

    def initial_dates_for_monthly
      period_start_date = loan.start_date.to_date.next_month
      loan.period_count.times.inject([]) do |arr, _|
        arr << period_start_date
        period_start_date = period_start_date.next_month
        arr
      end
    end

    def initial_dates_for_every_three_days
      period_start_date = (loan.start_date-1.day).to_date + 3.days
      loan.period_count.times.inject([]) do |arr, _|
        arr << period_start_date
        period_start_date = period_start_date + 3.days
        arr
      end
    end
  end
end
