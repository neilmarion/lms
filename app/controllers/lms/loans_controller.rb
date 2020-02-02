module Lms
  class LoansController < ApplicationController
    def show
      @loan = Loan.find(params[:id])
      @current_scenario = @loan.current_scenario(params[:scenario])
    end
  end
end
