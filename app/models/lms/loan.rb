module Lms
  class Loan < ApplicationRecord
    has_many :actual_transactions
    accepts_nested_attributes_for :actual_transactions

    has_many :expected_transactions
    accepts_nested_attributes_for :expected_transactions

    has_many :payments
    accepts_nested_attributes_for :payments

    after_create :create_initial_expected_transactions

    # Loan statuses
    EARLY = "early"
    LATE = "late"
    ONTIME = "ontime"

    def loan_state
      @loan_state || LoanState.new(self)
    end

    def do_balance
      balancer = Balancer.new(self, self.date_today || Date.today)
      balancer.execute
    end

    def initial_balance
      expected_payment_per_period * period_count
    end

    def expected_payment_per_period
      AmortizationCalculator.payment_per_period({
        amount: amount,
        interest: interest,
        period_count: period_count,
      })
    end

    def create_initial_expected_transactions
      initial_repayment_schedule = InitialExpectedTransactionsScheduleMapper.new(self).execute
      initial_repayment_schedule.map do |date, value|
        expected_transactions.create({
          date: date,
          amount: value[:interest],
          kind: ExpectedTransaction::INIT_INTEREST,
        })

        expected_transactions.create({
          date: date,
          amount: value[:principal],
          kind: ExpectedTransaction::INIT_PRINCIPAL,
        })
      end
    end

    def date_of_balance
      initial_repayment_dates.sort.last
    end

    def initial_balance
      loan_state.initial_balance
    end

    def initial_repayment_dates
      self.expected_transactions.where(kind: [
        ExpectedTransaction::INIT_PRINCIPAL,
        ExpectedTransaction::INIT_INTEREST,
      ]).pluck(:date).uniq
    end

    def date_of_balance
      self.initial_repayment_dates.sort.last
    end

    def current_date
      loan_state.current_date
    end

    def remaining_balance
      loan_state.remaining_balance
    end

    def remaining_principal
      loan_state.remaining_principal
    end

    def remaining_interest
      loan_state.remaining_interest
    end

    def paid_balance
      loan_state.paid_balance
    end

    def paid_interest
      loan_state.paid_interest
    end

    def paid_principal
      loan_state.paid_principal
    end

    def pay_to_balance
      loan_state.pay_to_balance
    end

    def expected_balance
      loan_state.expected_balance
    end

    def status
      loan_state.status
    end

    def interest_fees_sum
      expected_transactions.where(kind: [ExpectedTransaction::INTEREST_FEE]).pluck(:amount).sum
    end
  end
end
