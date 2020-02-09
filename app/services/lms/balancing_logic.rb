module Lms
  class BalancingLogic
    attr_accessor :base_payment_dates, :date_of_balance, :sequence_logic, :transaction_date

    def initialize(sequence_logic, base_payment_dates, date_of_balance, transaction_date)
      @sequence_logic = sequence_logic
      @date_of_balance = date_of_balance.to_s
      @base_payment_dates = base_payment_dates.map(&:to_s)
      @transaction_date = transaction_date.to_s
    end

    def execute
      table = sequence_logic.execute
      if is_ontime?(table)
        [balance_after_ontime, Loan::ONTIME]
      elsif is_late?(table)
        [balance_after_late, Loan::LATE]
      end
    end

    private

    def is_ontime?(table)
      row = table[date_of_balance]
      row[:zzz_bal].round(0) <= 0
    end

    def is_late?(table)
      row = table[date_of_balance]
      row[:zzz_bal].round(0) > 0
    end

    def balance_after_ontime
      loop.inject([]) do |adjustment_transactions|
        table = sequence_logic.execute
        return table if table[date_of_balance][:zzz_bal].round(2) == 0

        table.each do |date, row|
          if (base_payment_dates.include? date) && (row[:zzz_bal].round(2) < 0)
            adjustment_transactions << { date: date, amount: row[:zzz_bal]*-1 }
            sequence_logic.add_transaction(adjustment_transactions.last)
            break
          end
        end

        adjustment_transactions
      end
    end

    def balance_after_late
      loop.inject([]) do |adjustment_transactions|
        table = sequence_logic.execute
        return calculate_adjustment if table[date_of_balance][:zzz_bal].round(2) == 0

        adjustment_transactions << { date: transaction_date, amount: -1*table[date_of_balance][:zzz_bal] }
        sequence_logic.add_transaction(adjustment_transactions.last)
        adjustment_transactions
      end
    end

    def calculate_adjustment
      { new_balance: sequence_logic.transactions.map{ |x| x[:amount] }.sum }
    end
  end
end
