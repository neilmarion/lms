module Lms
  class Loan < ApplicationRecord
    has_many :actual_events
    accepts_nested_attributes_for :actual_events

    after_create :calculate_expected_payments

    def daily_interest_map
      @daily_interest_map ||= DailyInterestMapper.new(self).execute
    end

    def daily_expected_payment_map
      @daily_expected_payment_map ||= DailyExpectedPaymentMapper.new(self).execute
    end

    def current_scenario
      @current_scenario ||= scenario_service.execute
    end

    def current_balance
      scenario_service.balance
    end

    def expected_payment_per_period
      @payment_per_period ||= AmortizationCalculator.payment_per_period({
        amount: amount,
        interest: interest,
        period_count: period_count
      })
    end

    def calculate_expected_payments
      expected_payment_dates = InitialExpectedPaymentsMapper.new(self).execute
      update_attributes(expected_payments: expected_payment_dates)
    end

    def scenario_service
      @scenario_service ||= LoanScenarioMachine2.new(self)
    end

    def execute_balancing
      @adjustment_events, @happened = Lms::BalanceComputer.new(self).execute
    end

    def initial_balance
      @initial_balance ||= self.expected_payments.values.sum
    end

    def adjustment_summary
      adjustment_events, happened = execute_balancing

      case happened
      when "early"
        expected_payments_temp = {}
        self.expected_payments.each do |x, y|
          expected_payments_temp[x] = y if x > self.actual_events.last.date
        end


        expected_payments_temp.keys.each do |date|
          expected_payments_temp[date] = self.expected_payments[date] - adjustment_events.select{ |x| x[:date] == date }.map{ |x| x[:amount] }.sum
        end

        schedule = expected_payments_temp.map do |date, amount|
          "#{date} - #{amount.round(2)}"
        end

        balance = expected_payments_temp.values.sum

        "CURRENT BALANCE: #{balance.round(2)}<br>Customer paid early hence the adjustments to the repayment schedule<br>#{schedule.join('<br>')}"
      when "late"
        additional_payment = adjustment_events.map{ |x| x[:amount] }.sum.round(2)

        balance = initial_balance - additional_payment + self.actual_events.map{ |x| x.data["amount"] }.sum

        "CURRENT BALANCE: #{balance.round(2)}<br>Customer paid late hence an additional payment of #{-1*additional_payment} on #{adjustment_events.first[:date]}"
      else
        balance = initial_balance + self.actual_events.map{ |x| x.data["amount"] }.sum.round(2)

        "CURRENT BALANCE: #{balance.round(2)}<br>No Adjustments needed"
      end
    end
  end
end
