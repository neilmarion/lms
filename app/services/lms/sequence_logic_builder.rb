module Lms
  class SequenceLogicBuilder
    attr_accessor :loan, :current_date, :logic

    def initialize(loan, current_date)
      @loan = loan
      @current_date = current_date
    end

    def execute
      actual_txns = transform_transactions(realized_actual_transactions)
      expected_txns = transform_transactions(unrealized_expected_transactions)
      txns = actual_txns + expected_txns

      Lms::SequenceLogic.new(loan.amount, daily_interest_map, txns)
    end

    private

    def realized_actual_transactions
      loan.actual_transactions.where("created_at <= ?", DateTime.strptime(current_date.to_s, "%Y-%m-%d"))
    end

    def unrealized_expected_transactions
      loan.expected_transactions.where("date > ?", current_date).where(kind: ["init_interest", "init_principal"])
    end

    def daily_interest_map
      mapper = DailyInterestMapper.new(loan.start_date, loan.interest, loan.period, loan.period_count)
      mapper.execute
    end

    def transform_transactions(txns)
      txns.map do |txn|
        date = case txn.class.name
               when "Lms::ExpectedTransaction"
                { date: txn.date.to_s, amount: -1*txn.amount }
               when "Lms::ActualTransaction"
                { date: txn.created_at.strftime("%Y-%m-%d"), amount: txn.amount }
               end

      end
    end
  end
end
