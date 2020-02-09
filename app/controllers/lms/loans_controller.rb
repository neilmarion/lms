module Lms
  class LoansController < ApplicationController
    def new
      @loan = Loan.new
    end

    def create
      @loan = Loan.create(loan_params)
      @loan.update_attributes(date_today: @loan.start_date)
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

    def change_date
      @loan = Loan.find(params[:id])
      @loan.update_attributes(date_today: @loan.date_today + 1.day)
      redirect_to loan_path(@loan.id)
    end
  end
end
