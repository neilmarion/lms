module Lms
  class Loan < ApplicationRecord
    has_many :actual_transactions
    accepts_nested_attributes_for :actual_transactions

    has_many :expected_payments
    accepts_nested_attributes_for :expected_payments

    after_create :create_initial_repayments

    def expected_payment_per_period
      @payment_per_period ||= AmortizationCalculator.payment_per_period({
        amount: amount,
        interest: interest,
        period_count: period_count,
      })
    end

    def create_initial_repayments
      initial_repayment_schedule = InitialRepaymentScheduleMapper.new(self).execute
      initial_repayment_schedule.map do |date, value|
        expected_payments.create({
          date: date,
          amount: initial_balance,
          name: ExpectedPayment::INITIAL_BALANCE,
        })
      end
    end

    def initial_balance
      @initial_balance ||= expected_payment_per_period * period_count
    end

    def balance
      expected_transactions.pluck(:amount).sum - actual_transactions.pluck(:amount).sum
    end
  end
end
