module Lms
  class InitialExpectedTransactionsScheduleMapper
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      period_due_date = loan.start_date.next_month
      txns = loan.period_count.times.inject([]) do |arr|
        arr << { date: period_due_date.strftime(DailyInterestMapper::DATE_ID_FORMAT), amount: -1*loan.expected_payment_per_period }
        period_due_date = period_due_date.next_month
        arr
      end

      service = AmortizationLogic.new(loan.amount, daily_interest_map, txns)
      table = service.execute

      period_due_date = loan.start_date.next_month
      loan.period_count.times.inject({}) do |initial_repayment_schedule|
        date = period_due_date.strftime(DailyInterestMapper::DATE_ID_FORMAT)
        initial_repayment_schedule[
          date
        ] = { interest: -1*table[date][:int_chg], principal: -1*table[date][:pri_chg] }
        period_due_date = period_due_date.next_month
        initial_repayment_schedule
      end
    end

    def daily_interest_map
      mapper = DailyInterestMapper.new(loan.start_date, loan.interest, loan.period, loan.period_count)
      mapper.execute
    end
  end
end
