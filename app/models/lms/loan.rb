module Lms
  class Loan < ApplicationRecord
    has_many :actual_events
    accepts_nested_attributes_for :actual_events

    after_create :calculate_expected_payments

    def daily_interest_map
      @daily_interest_map ||= DailyInterestMapper.new(self).execute
    end

    def daily_expected_payment_map
      @daily_expected_payment_map ||= DailyExpectedPaymentMapper.new(self).execute
    end

    def current_scenario(scenario)
      @current_scenario ||= LoanScenarioMachine.new(self).execute(scenario)
    end

    def expected_payment_per_period
      @payment_per_period ||= AmortizationCalculator.payment_per_period({
        amount: amount,
        interest: interest,
        period_count: period_count
      })
    end

    def calculate_expected_payments
      expected_payment_dates = InitialLoanExpectedPayments.new(self).execute
      update_attributes(expected_payments: expected_payment_dates)
    end
  end
end
