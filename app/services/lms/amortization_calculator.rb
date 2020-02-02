module Lms
  class AmortizationCalculator
    def self.payment_per_period(amount:, interest:, period_count:)
      amount*((interest*((1.to_f+interest)**period_count.to_f))/(((1.to_f+interest)**period_count)-1.to_f))
    end
  end
end
