module Lms
  class Balancer
    attr_accessor :loan, :current_date

    def initialize(loan, current_date)
      @loan = loan
      @current_date = current_date
    end

    def execute
      sequence_logic = SequenceLogicBuilder.new(loan, current_date).execute
      initial_repayment_dates = loan.initial_repayment_dates
      date_of_balance = loan.date_of_balance
      return unless date_of_balance
      balancing_logic = BalancingLogic.new(sequence_logic, initial_repayment_dates, date_of_balance, current_date)
      adjustments, result = balancing_logic.execute
      sequence_logic = balancing_logic.sequence_logic
      table = sequence_logic.execute

      if ["late", "early"].include? result
        # NOTE: Get realized schedule
        actual_schedule = loan.repayment_schedule.inject({}) do |hash, (date, value)|
          if current_date.to_s > date
            hash[date] = value
          end

          hash
        end

        # NOTE: Get today's value
        actual_schedule[current_date.to_s] = -table[current_date.to_s][:tot_chg]

        expected_schedule = loan.repayment_schedule.inject({}) do |hash, (date, value)|
          if current_date.to_s < date
            hash[date] = -table[date][:tot_chg]
          end

          hash
        end

        updated_schedule = actual_schedule.merge(expected_schedule)
        loan.update_attributes(repayment_schedule: updated_schedule)
      end

      [table, result]
    end
  end
end
