module Lms
  class Loan < ApplicationRecord
    has_many :scenario_configs
    has_many :actual_events
  end
end
