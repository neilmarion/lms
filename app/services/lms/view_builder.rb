module Lms
  class ViewBuilder
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      build_view
    end

    private

    def get_actual_txns
      loan.actual_transactions.inject([]) do |arr, txn|
        arr << { date: date, charges: nil, credits: txn.amount, balance: nil, note: nil }
      end
    end

    def build_view
      balanced_sequence = loan.loan_state.balanced_sequence
      actual_sequence = loan.loan_state.actual_sequence
      current_date = (loan.date_today || Date.today)
      status = loan.status

      figures = balanced_sequence.inject({}) do |hash, (date, row)|
        if row[:tot_chg] != 0
          int_chg = row[:int_chg].abs.round(2)
          pri_chg = row[:pri_chg].abs.round(2)
          tot_chg = row[:tot_chg].abs.round(2)

          if current_date <= date.to_date
            hash[date] = {
              date: date.to_s,
              ctot_ipd: int_chg,
              ctot_ppd: pri_chg,
              ctot_bpd: tot_chg,
              ptot_ipd: nil,
              ptot_ppd: nil,
              ptot_bpd: nil,
              note: status == "late" && date.to_date == current_date ? "pay immediately" : "payment due",
              due: status == "late" && date.to_date == current_date ? "due-today" : "ontime",
            }
          else
            hash[date] = {
              date: date.to_s,
              ctot_ipd: nil,
              ctot_ppd: nil,
              ctot_bpd: nil,
              ptot_ipd: int_chg,
              ptot_ppd: pri_chg,
              ptot_bpd: tot_chg,
              note: "payment",
              due: nil,
            }
          end
        end

        hash
      end

      aipd = actual_sequence[loan.date_of_balance.to_s][:tot_ipd].abs.round(2)
      appd = actual_sequence[loan.date_of_balance.to_s][:tot_ppd].abs.round(2)
      abpd = actual_sequence[loan.date_of_balance.to_s][:tot_bpd].abs.round(2)
      bipd = balanced_sequence[loan.date_of_balance.to_s][:tot_ipd].abs.round(2)
      bppd = balanced_sequence[loan.date_of_balance.to_s][:tot_ppd].abs.round(2)
      bbpd = balanced_sequence[loan.date_of_balance.to_s][:tot_bpd].abs.round(2)

      { figures: figures, totals: {
        bipd: bipd,
        bppd: bppd,
        bbpd: bbpd,
        aipd: aipd,
        appd: appd,
        abpd: abpd
      }}
    end
  end
end
