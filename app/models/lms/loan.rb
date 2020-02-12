module Lms
  class Loan < ApplicationRecord
    has_many :actual_transactions
    accepts_nested_attributes_for :actual_transactions

    has_many :payments
    accepts_nested_attributes_for :payments

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
      @eppp ||= AmortizationCalculator.payment_per_period({
        amount: amount,
        interest: interest,
        period_count: period_count,
      })
    end

    def date_of_balance
      initial_repayment_dates.sort.last
    end

    def initial_balance
      loan_state.initial_balance
    end

    def initial_repayment_dates
      RepaymentDates.new(self).execute
    end

    def date_of_balance
      initial_repayment_dates.sort.last
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
  end
end
