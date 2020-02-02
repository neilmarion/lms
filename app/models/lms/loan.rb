module Lms
  class Loan < ApplicationRecord
    has_many :actual_events

    def daily_interest_map
      @daily_interest_map ||= DailyInterestMapper.new(self).execute
    end

    def daily_expected_payment_map
      @daily_expected_payment_map ||= DailyExpectedPaymentMapper.new(self).execute
    end

    def current_scenario
      @current_scenario ||= LoanScenarioMachine.new(self).execute
    end

    def expected_payment_per_period
      @payment_per_period ||= AmortizationCalculator.payment_per_period({
        amount: amount,
        interest: interest,
        period_count: period_count
      })
    end
  end
end
