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
      next_due = 0;

      figures = balanced_sequence.inject({}) do |hash, (date, row)|
        if row[:tot_chg] != 0
          int_chg = row[:int_chg].abs.round(2)
          pri_chg = row[:pri_chg].abs.round(2)
          tot_chg = row[:tot_chg].abs.round(2)

          if current_date == date.to_date
            if status == "late"
              a_tot_chg = actual_sequence[date.to_s][:tot_chg].abs.round(2)
              a_pri_chg = actual_sequence[date.to_s][:pri_chg].abs.round(2)
              a_int_chg = actual_sequence[date.to_s][:int_chg].abs.round(2)

              if a_tot_chg != 0
                hash[date] = {
                  date: date.to_s,
                  ctot_ipd: (int_chg - a_int_chg).abs.round(2),
                  ctot_ppd: (pri_chg - a_pri_chg).abs.round(2),
                  ctot_bpd: (tot_chg - a_tot_chg).abs.round(2),
                  ptot_ipd: a_int_chg,
                  ptot_ppd: a_pri_chg,
                  ptot_bpd: a_tot_chg,
                  note: "pay now",
                  due: "due-today",
                }
              else
                hash[date] = {
                  date: date.to_s,
                  ctot_ipd: int_chg,
                  ctot_ppd: pri_chg,
                  ctot_bpd: tot_chg,
                  ptot_ipd: nil,
                  ptot_ppd: nil,
                  ptot_bpd: nil,
                  note: "pay now",
                  due: "due-today",
                }
              end
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
                due: "ontime",
              }
            end
          elsif current_date < date.to_date
            hash[date] = {
              date: date.to_s,
              ctot_ipd: int_chg,
              ctot_ppd: pri_chg,
              ctot_bpd: tot_chg,
              ptot_ipd: nil,
              ptot_ppd: nil,
              ptot_bpd: nil,
              note: "payment due",
              due: next_due == 0 ? "next-due" : "not-yet-due",
            }
            next_due = 1
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

      { figures: figures, totals: {
        bipd: loan.remaining_interest.round(2),
        bppd: loan.remaining_principal.round(2),
        bbpd: loan.remaining_balance.round(2),
        aipd: loan.paid_interest.round(2),
        appd: loan.paid_principal.round(2),
        abpd: loan.paid_balance.round(2),
      }}
    end
  end
end
