module Lms
  class LoansController < ApplicationController
    def new
      @loan = Loan.new
    end

    def create
      @loan = Loan.create(loan_params)
      redirect_to loan_path(@loan.id)
    end

    def show
      @loan = Loan.find(params[:id])
      @view = ViewBuilder.new(@loan).execute
    end

    def loan_params
      params.require(:loan).permit(
        :period, :amount, :interest, :period_count, :start_date,
      )
    end
  end
end
