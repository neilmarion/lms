module Lms
  class Loan < ApplicationRecord
    has_many :scenario_configs
    has_many :actual_events

    after_create :build_scenario_configs

    def build_scenario_configs
      build_actual_plus_worst_scenario_config
      build_actual_plus_best_scenario_config
    end

    def build_actual_plus_worst_scenario_config
      self.scenario_configs.create(name: "actual_plus_worst")
    end

    def build_actual_plus_worst_scenario_config
      repayment_dates = calculate_scheduled_payments
      self.scenario_configs.create(name: "actual_plus_best", data: { scheduled_repayments: calculate_scheduled_payments })
    end

    def calculate_scheduled_payments
      repayment_dates = []
      n = (term_count/30)
      next_month = nil

      n.times.map do
        next_month = start_date.nexth_month
        repayment_dates << next_month.strftime("%Y-%m-%d")
      end

      last_day = (start_date + term_count.days)

      repayment_dates << last_day.strftime("%Y-%m-%d")
      repayment_dates = repayment_dates.uniq

      payment_per_month = calculate_ending_balance / repayment_dates.count.to_f

      repayment_dates.map do |repayment_date|
        {date: repayment_date, amount: payment_per_month}
      end
    end

    def calculate_ending_balance
      Lms::AmortizationCalculator.payment_per_period({
        init_principal: amount,
        daily_interest_rate: interest_per_day,
        period_count: term_count,
      }) * term_count.to_f
    end
  end
end
