module Lms
  class BalancingLogic
    attr_accessor :base_payment_dates, :date_of_balance, :amortization_logic, :transaction_date

    def initialize(amortization_logic, base_payment_dates, date_of_balance, transaction_date)
      @amortization_logic = amortization_logic
      @date_of_balance = date_of_balance
      @base_payment_dates = base_payment_dates
      @transaction_date = transaction_date
    end

    def execute
      table = amortization_logic.execute

      return nil if amortization_logic.blank?
      # NOTE: Before, this is round(2). But changed to round(0) to ignore very minute values like 0.000006
      if is_early?(table)
        [balance_after_early, "early"]
      elsif is_late?(table)
        [balance_after_late, "late"]
      end
    end

    private

    def is_early?(table)
      row = table[date_of_balance]
      row[:zzz_bal].round(0) < 0
    end

    def is_late?(table)
      row = table[date_of_balance]
      row[:zzz_bal].round(0) > 0
    end

    def balance_after_early
      loop.inject([]) do |adjustment_transactions|
        table = amortization_logic.execute
        return table if table[date_of_balance][:zzz_bal].round(2) == 0

        table.each do |date, row|
          if (base_payment_dates.include? date) && (row[:zzz_bal].round(2) < 0)
            adjustment_transactions << { date: date, amount: row[:zzz_bal]*-1 }
            amortization_logic.add_transaction(adjustment_transactions.last)
            break
          end
        end

        adjustment_transactions
      end
    end

    def balance_after_late
      loop.inject([]) do |adjustment_transactions|
        table = amortization_logic.execute
        return calculate_adjustment if table[date_of_balance][:zzz_bal].round(2) == 0

        adjustment_transactions << { date: transaction_date, amount: -1*table[date_of_balance][:zzz_bal] }
        amortization_logic.add_transaction(adjustment_transactions.last)
        adjustment_transactions
      end
    end

    def calculate_adjustment
      { new_balance: amortization_logic.transactions.map{ |x| x[:amount] }.sum }
    end
  end
end
