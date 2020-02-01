module Lms
  class AmortizationCalculator
    def self.payment_per_period(init_principal:, daily_interest_rate:, period_count:)
      init_principal*((daily_interest_rate*((1.to_f+daily_interest_rate)**period_count.to_f))/(((1.to_f+daily_interest_rate)**period_count)-1.to_f))
    end
  end
end
