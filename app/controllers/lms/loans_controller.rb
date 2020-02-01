module Lms
  class LoansController < ApplicationController
    def show
      loan = Loan.find(params[:id])
      sm = Lms::ScenarioMachine.new(loan)
      @scenarios = sm.execute
    end
  end
end
