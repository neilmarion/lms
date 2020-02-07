require "rails_helper"

module Lms
  describe AmortizationCalculator do
    it "returns payment per period" do
      result = described_class.payment_per_period(amount: 100000, interest: 0.01, period_count: 6)
      expect(result).to eq 17254.836671088106
    end
  end
end
