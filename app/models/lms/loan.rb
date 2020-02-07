module Lms
  class Loan < ApplicationRecord
    has_many :actual_events
    accepts_nested_attributes_for :actual_events

    after_create :calculate_initial_repayment_schedule

    def expected_payment_per_period
      @payment_per_period ||= AmortizationCalculator.payment_per_period({
        amount: amount,
        interest: interest,
        period_count: period_count,
      })
    end

    def calculate_initial_repayment_schedule
      initial_repayment_schedule = InitialRepaymentScheduleMapper.new(self).execute
      update_attributes(initial_repayment_schedule: initial_repayment_schedule)
    end

    def initial_balance
      @initial_balance ||= self.initial_repayment_schedule.values.sum
    end
  end
end
