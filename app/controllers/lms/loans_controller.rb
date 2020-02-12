module Lms
  class LoansController < ApplicationController
    before_filter :negate_amount, only: [:update]
    before_filter :assign_note, only: [:update]

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

    def table
      @loan = Loan.find(params[:id])
    end

    def loan_params
      params.require(:loan).permit(
        :period, :amount, :interest, :period_count, :start_date,
        actual_transactions_attributes: [:kind, :amount, :updated_at, :created_at, :note],
      )
    end

    def change_date
      @loan = Loan.find(params[:id])
      @loan.update_attributes(date_today: @loan.date_today + 1.day)
      @loan.do_balance
      redirect_to loan_path(@loan.id)
    end

    def negate_amount
      params[:loan][:actual_transactions_attributes]["0"][:amount] =
        -params[:loan][:actual_transactions_attributes]["0"][:amount].to_f
    end

    def assign_note
      params[:loan][:actual_transactions_attributes]["0"][:note] =
        params[:loan][:actual_transactions_attributes]["0"][:kind]
    end

    def goto_date
      loan = Loan.find(params[:id])
      new_date = params[:current_date][:date].to_date

      if new_date > loan.date_today
        loop do
          loan.update_attributes(date_today: loan.date_today + 1.day)
          loan.do_balance
          break if loan.date_today == new_date
        end
      elsif new_date < loan.date_today
        loan.actual_transactions.where("created_at >= ? AND created_at < ?", new_date, loan.date_today + 1.day).destroy_all
        loan.update_attributes(date_today: new_date)
        loan.do_balance
      end

      redirect_to loan_path(params[:id])
    end
  end
end
