module Lms
  class SequenceLogic
    attr_accessor :amount, :daily_interest_map, :transactions

    def initialize(amount, daily_interest_map, transactions)
      @amount = amount
      @daily_interest_map = daily_interest_map
      @transactions = transactions
    end

    def execute
      build_table
    end

    def add_transaction(added_transaction)
      transactions << added_transaction
      transactions.compact!
    end

    private

    def build_table
      # date
      # aaa_bal = beginning balance
      # aaa_pri = beginning principal
      # day_int = daily interest accrued
      # tot_int = total interest accrued
      #
      # tot_chg = total change (negative for payment, positive for to principal)
      # int_chg = interest change
      # pri_chg = principal change
      #
      # tot_ipd = total interest paid
      # tot_ppd = total principal paid
      # tot_bpd = total balance paid
      #
      # zzz_int = ending interest
      # zzz_pri = ending principal
      # zzz_bal = ending balance

      temp = {zzz_bal: amount.to_f, zzz_pri: amount.to_f}
      daily_interest_map.inject({}) do |table, (date, int)|
        aaa_bal = temp[:zzz_bal]
        aaa_pri = temp[:zzz_pri]
        day_int = temp[:zzz_pri].to_f * int
        tot_int = temp[:zzz_int].to_f + day_int
        tot_chg = transaction_amount_sum(date)
        int_chg = 0
        pri_chg = 0

        int_chg, pri_chg = calculate_changes(int_chg, pri_chg, tot_chg, tot_int)

        zzz_int = tot_int + int_chg
        zzz_pri = aaa_pri + pri_chg
        zzz_bal = aaa_bal + day_int + tot_chg

        tot_ipd = temp[:tot_ipd].to_f + int_chg
        tot_ppd = temp[:tot_ppd].to_f + pri_chg
        tot_bpd = temp[:tot_bpd].to_f + tot_chg

        temp = {
          aaa_bal: aaa_bal,
          aaa_pri: aaa_pri,
          day_int: day_int,
          tot_int: tot_int,
          tot_chg: tot_chg,
          int_chg: int_chg,
          pri_chg: pri_chg,
          tot_ipd: tot_ipd,
          tot_ppd: tot_ppd,
          tot_bpd: tot_bpd,
          zzz_int: zzz_int,
          zzz_pri: zzz_pri,
          zzz_bal: zzz_bal,
        }

        table[date] = temp
        table
      end
    end

    def calculate_changes(int_chg, pri_chg, tot_chg, tot_int)
      # If tot_chg is negative, that means
      # the customer has paid some amount
      if tot_chg < 0
        # Pay off interest before principal
        if (tot_chg)*-1 >= tot_int
          int_chg = tot_int*-1
          pri_chg = tot_chg - int_chg
        else
          int_chg = tot_chg
        end
      # If tot_chg is positive, that means
      # the customer added principal
      elsif tot_chg > 0
        pri_chg = tot_chg
      end

      return int_chg, pri_chg
    end

    def transaction_amount_sum(date)
      amounts = transactions.select{ |x| x[:date] == date }.map{ |x| x[:amount].to_f }.sum
    end
  end
end
