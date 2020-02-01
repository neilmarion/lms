module Lms
  class ActualScenarioMachine
    attr_accessor :scenario

    def initialize
      scenario = [] # Array of Hashes
    end

    def execute
    end

    private

    def create_scenario
      Event.all.each do |event|

      end
    end

    def get_day_count(start_date, end_date)
      (DateTime.strptime("2020-03-31", "%Y-%m-%d") - Date.today).to_i
    end
  end
end
