module Lms
  class LoansController < ApplicationController
    def show
      @loan = Loan.find(params[:id])
    end
  end
end
