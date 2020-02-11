module Lms
  class LoanState
    attr_accessor :sequence, :loan, :status

    def initialize(loan)
      @loan = loan
      build_sequence
    end

    def remaining_balance
      sequence[loan.date_of_balance.to_s][:tot_bpd].abs-
        sequence[current_date.to_s][:tot_bpd].abs
    end

    def remaining_principal
      sequence[loan.date_of_balance.to_s][:tot_ppd].abs -
        sequence[current_date.to_s][:tot_ppd].abs
    end

    def remaining_interest
      sequence[loan.date_of_balance.to_s][:tot_ipd].abs -
        sequence[current_date.to_s][:tot_ipd].abs
    end

    def paid_balance
      sequence[current_date.to_s][:tot_bpd].abs
    end

    def paid_principal
      sequence[current_date.to_s][:tot_ppd].abs
    end

    def paid_interest
      sequence[current_date.to_s][:tot_ipd].abs
    end

    def pay_to_balance
      sequence[current_date.to_s][:zzz_bal].abs
    end

    def expected_balance
      sequence[date_of_balance.to_s][:tot_bpd].abs
    end

    def zzz_bal
      sequence[date_of_balance.to_s][:zzz_bal]
    end

    private

    def build_sequence
      @sequence, @status = Balancer.new(loan, current_date).execute
    end

    def current_date
      loan.date_today || Date.today
    end
  end
end
