module Lms
  class LoansController < ApplicationController
    before_filter :negate_amount, only: [:update]

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

    def update
      @loan = Loan.find(params[:id])
      @loan.update_attributes(loan_params)
      redirect_to loan_path(@loan.id)
    end

    def loan_params
      params.require(:loan).permit(
        :period, :amount, :interest, :period_count, :start_date,
        actual_transactions_attributes: [:kind, :amount, :updated_at, :created_at],
      )
    end

    def change_date
      @loan = Loan.find(params[:id])
      @loan.update_attributes(date_today: @loan.date_today + 1.day)
      redirect_to loan_path(@loan.id)
    end

    def negate_amount
      params[:loan][:actual_transactions_attributes]["0"][:amount] =
        -params[:loan][:actual_transactions_attributes]["0"][:amount].to_f
    end
  end
end
