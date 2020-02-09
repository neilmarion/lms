module Lms
  class LoansController < ApplicationController
    def new
      @loan = Loan.new
    end
  end
end
