module Lms
  class LoanState
    attr_accessor :actual_sequence, :expected_sequence, :loan

    def initialize(loan)
      @loan = loan
      build_actual_sequence
      build_expected_sequence
    end

    def remaining_balance
      (expected_sequence[date_of_balance.to_s][:tot_bpd].abs + interest_fees_sum)-
        actual_sequence[current_date.to_s][:tot_bpd].abs
    end

    def remaining_principal
      expected_sequence[date_of_balance.to_s][:tot_ppd].abs -
        actual_sequence[current_date.to_s][:tot_ppd].abs
    end

    def remaining_interest
      (expected_sequence[date_of_balance.to_s][:tot_ipd].abs + interest_fees_sum) -
        actual_sequence[current_date.to_s][:tot_ipd].abs
    end

    def paid_balance
      actual_sequence[current_date.to_s][:tot_bpd].abs
    end

    def paid_principal
      actual_sequence[current_date.to_s][:tot_ppd].abs
    end

    def paid_interest
      actual_sequence[current_date.to_s][:tot_ipd].abs
    end

    def pay_to_balance
      actual_sequence[current_date.to_s][:zzz_bal].abs
    end

    def expected_balance
      expected_sequence[date_of_balance.to_s][:tot_bpd].abs
    end

    def zzz_bal
      expected_sequence[date_of_balance.to_s][:zzz_bal]
    end

    def expected_payment_per_period
      AmortizationCalculator.payment_per_period({
        amount: loan.amount,
        interest: loan.interest,
        period_count: loan.period_count,
      })
    end

    def initial_balance
      expected_payment_per_period * loan.period_count
    end

    def initial_repayment_dates
      loan.expected_transactions.where(kind: [
        ExpectedTransaction::INIT_PRINCIPAL,
        ExpectedTransaction::INIT_INTEREST,
      ]).pluck(:date).uniq
    end

    def date_of_balance
      initial_repayment_dates.sort.last
    end

    def interest_fees_sum
      loan.expected_transactions.where(kind: [ExpectedTransaction::INTEREST_FEE]).pluck(:amount).sum
    end

    private

    def build_actual_sequence
      sequence_logic = SequenceLogicBuilder.new(
        loan, current_date, SequenceLogicBuilder::ACTUAL).execute
      @actual_sequence = sequence_logic.execute
    end

    def build_expected_sequence
      sequence_logic = SequenceLogicBuilder.new(
        loan, current_date, SequenceLogicBuilder::EXPECTED).execute
      @expected_sequence = sequence_logic.execute
    end

    def current_date
      loan.date_today || Date.today
    end
  end
end
