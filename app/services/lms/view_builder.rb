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
      actual_sequence = loan.loan_state.actual_sequence
      balanced_sequence = loan.loan_state.balanced_sequence

      actual_transactions = loan.actual_transactions.inject({}) do |hash, value|
        hash[value.created_at.to_date] = { amount: value.amount.round(2), note: value.note }
        hash
      end

      expected_transactions = loan.expected_transactions.where(kind: "interest_fee").inject({}) do |hash, value|
        hash[value.date] = { amount: value.amount.round(2), note: value.note }
        hash
      end

      loan.initial_repayment_dates.inject({}) do |hash, date|
        actual_txns = actual_transactions.select do |d, value|
          d.between?(date.last_month+1.day, date+1.day)
        end.inject([]) do |arr, (d, txn)|
          arr << {
            date: d.to_s,
            ctot_ipd: nil,
            ctot_ppd: nil,
            ctot_bpd: nil,
            camount: nil,
            ptot_ipd: balanced_sequence[d.to_s][:tot_ipd].round(2),
            ptot_ppd: balanced_sequence[d.to_s][:tot_ppd].round(2),
            ptot_bpd: balanced_sequence[d.to_s][:tot_bpd].round(2),
            pamount: txn[:amount],
            note: txn[:note],
          }

          arr
        end

        expected_txns = expected_transactions.select do |d, value|
          d.between?(date.last_month+1.day, date+1.day)
        end.inject([]) do |arr, (d, txn)|
          arr << {
            date: d.to_s,
            ctot_ipd: txn[:amount],
            ctot_ppd: 0,
            ctot_bpd: txn[:amount],
            camount: txn[:amount],
            ptot_ipd: nil,
            ptot_ppd: nil,
            ptot_bpd: nil,
            pamount: nil,
            note: txn[:note],
          }

          arr
        end

        hash[date] = {
          tot_bpd: balanced_sequence[date.to_s][:tot_bpd].round(2),
          tot_ppd: balanced_sequence[date.to_s][:tot_ppd].round(2),
          tot_ipd: balanced_sequence[date.to_s][:tot_ipd].round(2),
          txns: expected_txns + actual_txns,
        }

        hash
      end.sort
    end


    def transform_txns(txns)
      txns.map do |txn|
        date = case txn.class.name
               when "Lms::ExpectedTransaction"
                 { date: txn.date.to_s, charges: txn.amount, credits: nil, note: txn.note }
               when "Lms::ActualTransaction"
                 { date: txn.created_at.strftime("%Y-%m-%d"), charges: nil, credits: txn.amount, note: txn.note, kind: txn.kind }
               end
      end
    end

    def transform_amt(amt)
      if amt >= 0
        "#{amt.round(2).abs}"
      else
        "(#{amt.round(2).abs})"
      end
    end
  end
end
