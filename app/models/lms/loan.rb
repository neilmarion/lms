module Lms
  class Loan < ApplicationRecord
    has_many :actual_transactions
    accepts_nested_attributes_for :actual_transactions

    has_many :expected_transactions
    accepts_nested_attributes_for :expected_transactions

    has_many :payments
    accepts_nested_attributes_for :payments

    after_create :create_initial_expected_transactions

    def expected_payment_per_period
      @payment_per_period ||= AmortizationCalculator.payment_per_period({
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

    def initial_balance
      @initial_balance ||= expected_payment_per_period * period_count
    end

    def initial_repayment_dates
      @initial_repayment_dates ||= expected_transactions.where(kind: [
        ExpectedTransaction::INIT_PRINCIPAL,
        ExpectedTransaction::INIT_INTEREST,
      ]).pluck(:date).uniq
    end

    # NOTE: Date of balance is the last initial repayment date
    def date_of_balance
      initial_repayment_dates.sort.last
    end

    def expected_transactions_sum
      expected_transactions.pluck(:amount).sum
    end

    def expected_interest_transactions_sum
      expected_transactions.
        where(kind: [ExpectedTransaction::INIT_INTEREST, ExpectedTransaction::INTEREST]).
        pluck(:amount).sum
    end

    def expected_principal_transactions_sum
      expected_transactions.
        where(kind: [ExpectedTransaction::INIT_PRINCIPAL, ExpectedTransaction::PRINCIPAL]).
        pluck(:amount).sum
    end

    def state
      sequence_logic = Lms::LoanStateBuilder.new(self, current_date, LoanStateBuilder::FOR_CURRENT_STATE).execute
      table = sequence_logic.execute
      table[current_date.to_s]
    end

    def current_date
      Date.today
    end

    def remaining_balance
      state[:bal_rem]
    end

    def remaining_principal
      state[:pri_rem]
    end

    def remaining_interest
      state[:int_rem]
    end

    def paid_balance
      state[:tot_bpd]
    end

    def paid_interest
      state[:tot_ipd]
    end

    def paid_principal
      state[:tot_ppd]
    end
  end
end
