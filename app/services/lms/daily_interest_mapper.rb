module Lms
  class DailyInterestMapper
    DATE_ID_FORMAT = "%Y-%m-%d"
    attr_accessor :start_date, :interest, :period, :period_count

    def initialize(start_date, interest, period, period_count)
      @start_date = start_date
      @interest = interest
      @period = period
      @period_count = period_count
    end

    def execute
      case period
      when "daily"
      when "weekly"
      when "monthly"
        daily_interests_for_monthly
      when "quarterly"
      when "biannualy"
      when "annualy"
      end
    end

    private

    def daily_interests_for_monthly
      period_start_date = start_date + 1.day
      period_count.times.inject({}) do |hash, index|
        range = if index == 0
          (period_start_date.to_date-1.day)..period_start_date.next_month.to_date
        else
          period_start_date.to_date..period_start_date.next_month.to_date
        end

        daily_interest = interest / (range.count - 1)

        range.map{ |date| date.strftime(DATE_ID_FORMAT) }.map.with_index do |day, i|
          hash[day] = daily_interest
        end

        period_start_date = period_start_date.next_month
        hash
      end
    end
  end
end
