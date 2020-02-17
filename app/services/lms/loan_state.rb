module Lms
  class LoanState
    attr_accessor :balanced_sequence, :actual_sequence, :loan, :status

    def initialize(loan)
      @loan = loan
      build_sequences
    end

    def remaining_balance
      balanced_sequence[loan.date_of_balance.to_s][:tot_bpd].abs -
        actual_sequence[current_date.to_s][:tot_bpd].abs
    end

    def remaining_principal
      balanced_sequence[loan.date_of_balance.to_s][:tot_ppd].abs -
        actual_sequence[current_date.to_s][:tot_ppd].abs
    end

    def remaining_interest
      balanced_sequence[loan.date_of_balance.to_s][:tot_ipd].abs -
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
      balanced_sequence[date_of_balance.to_s][:tot_bpd].abs
    end

    def due_to_pay_now
      balanced_sequence[current_date.to_s][:tot_bpd].abs
    end

    def get_balanced_sequence_on_date(date)
      balanced_sequence, status = Balancer.new(loan, date).execute
      balanced_sequence
    end

    def demo_sequence
      sequence_logic = SequenceLogicBuilder.new(loan, current_date, "balancing").execute
      sequence_logic.execute
    end

    private

    def build_sequences
      @balanced_sequence, @status = Balancer.new(loan, current_date).execute
      sequence_logic = SequenceLogicBuilder.new(loan, current_date, "actual").execute
      @actual_sequence, s = sequence_logic.execute
    end

    def current_date
      loan.date_today || Date.today
    end
  end
end
