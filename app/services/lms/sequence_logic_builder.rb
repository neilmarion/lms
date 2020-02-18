module Lms
  class SequenceLogicBuilder
    attr_accessor :loan, :current_date, :logic, :purpose

    def initialize(loan, current_date, purpose="balancing")
      @loan = loan
      @current_date = current_date
      @purpose = purpose
    end

    def execute
      actual_txns = actual_transactions
      expected_txns = expected_transactions
      txns = actual_txns + expected_txns

      if purpose == "balancing"
        return Lms::SequenceLogic.new(loan.amount, daily_interest_map, txns)
      else
        return Lms::SequenceLogic.new(loan.amount, daily_interest_map, actual_txns)
      end
    end

    private

    def actual_transactions
      txns = loan.actual_transactions.where("created_at <= ?", DateTime.strptime(current_date.to_s, "%Y-%m-%d"))
      txns.map do |txn|
        { date: txn.created_at.strftime(Lms::DailyInterestMapper::DATE_ID_FORMAT), amount: txn.amount }
      end
    end

    def expected_transactions
      loan.initial_repayment_dates.inject([]) do |arr, date|
        arr << { date: date.to_s, amount: -loan.expected_payment_per_period } if date > current_date
        arr
      end
    end

    def daily_interest_map
      mapper = DailyInterestMapper.new(loan.start_date, loan.interest, loan.period, loan.period_count, loan.last_transaction_date)
      mapper.execute
    end
  end
end
