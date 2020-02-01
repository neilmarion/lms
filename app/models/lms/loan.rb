module Lms
  class Loan < ApplicationRecord
    has_many :scenario_configs
    has_many :actual_events

    after_create :build_scenario_configs

    def build_scenario_configs
      build_actual_plus_worst_scenario_config
      build_actual_plus_best_scenario_config
    end

    private

    def build_actual_plus_worst_scenario_config
      self.scenario_configs.create(name: "actual_plus_worst")
    end

    def build_actual_plus_worst_scenario_config
      repayment_dates = calculate_scheduled_repayment_dates
      self.scenario_configs.create(name: "actual_plus_best", data: { repayment_dates: repayment_dates })
    end

    def calculate_scheduled_repayment_dates
      repayment_dates = []
      n = (term_count/30)
      next_month = nil

      n.times.map do
        next_month = start_date.nexth_month
        repayment_dates << next_month.strftime("%Y-%m-%d")
      end

      last_day = (start_date + term_count.days)

      repayment_dates << last_day.strftime("%Y-%m-%d")
      repayment_dates.uniq
    end
  end
end
