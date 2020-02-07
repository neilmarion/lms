module Lms
  class LoanStateBuilder
    attr_accessor :loan

    def initialize
      @loan = loan
    end

    def execute
      actual_txns = transform_transactions(loan.actual_transactions)
      expected_txns = transform_transactions(unrealized_expected_transactions)
      txns = actual_txns + expected_txns

      logic = Lms::AmortizationLogic.new(loan.amount, daily_interest_map, txns)
      logic.execute
    end

    private

    def unrealized_expected_transactions
      loan.expected_transactions.
        where("date > ?", loan.actual_transactions.last.date)
    end

    def daily_interest_map
      mapper = DailyInterestMapper.new(loan.start_date, loan.interest, loan.period, loan.period_count)
      mapper.execute
    end

    def transform_transactions(txns)
      txns.map do |txn|
        { date: txn.strftime("%Y-%m-%d"), amount: -1*txn.amount }
      end
    end
  end
end
