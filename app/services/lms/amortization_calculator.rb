module Lms
  class AmortizationCalculator
    def self.payment_per_period(init_principal:, daily_interest_rate:, period_count:)
      init_principal*((daily_interest_rate*((1.0000+daily_interest_rate)**period_count))/(((1.0000+daily_interest_rate)**period_count)-1.0000))
    end
  end
end
