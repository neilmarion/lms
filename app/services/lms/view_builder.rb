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
      loan.initial_repayment_dates.inject([]) do |arr, date|
        init_txns = loan.expected_transactions.
          where(date: date, kind: [
            ExpectedTransaction::INIT_PRINCIPAL,
            ExpectedTransaction::INIT_INTEREST,
        ])

        date_range = (date.last_month+1.day)...(date+1.day)
        expected_txns = transform_txns(loan.expected_transactions.where(kind: [ExpectedTransaction::INTEREST, ExpectedTransaction::PRINCIPAL], date: date_range))
        actual_txns = transform_txns(loan.actual_transactions.where(created_at: date_range))
        txns = expected_txns + actual_txns

        arr << { date: date.to_s, charges: init_txns.pluck(:amount).sum.round(2).to_s, txns: txns.sort_by{ |x| x[:date] } }
        arr
      end
    end

    def transform_txns(txns)
      txns.map do |txn|
        date = case txn.class.name
               when "Lms::ExpectedTransaction"
                 { date: txn.date.to_s, charges: transform_amt(txn.amount), credits: nil, note: txn.note }
               when "Lms::ActualTransaction"
                 { date: txn.created_at.strftime("%Y-%m-%d"), charges: nil, credits: transform_amt(txn.amount), note: txn.note }
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
