module Lms
  class LoansController < ApplicationController
    before_filter :convert_amount_to_integer, only: [:update]
    before_filter :convert_custom_payment_amount_to_integer, only: [:create_custom_payment]

    def new
      @loan = Loan.new
    end

    def create
      @loan = Loan.create(loan_params)
      redirect_to loan_path(@loan.id)
    end

    def show
      @loan = Loan.find(params[:id])
      @current_scenario = @loan.current_scenario
    end

    def update
      @loan = Loan.find(params[:id])
      @loan.update_attributes(loan_params)
      redirect_to loan_path(@loan.id)
    end

    def loan_params
      @loan_params ||= params.require(:loan).permit(
        :period, :amount, :interest, :period_count, :start_date,
        actual_events_attributes: [{data: :amount}, :date, :name],
      )
    end

    def create_custom_payment
      @loan = Loan.find(params[:id])
      custom_payments = @loan.custom_payments
      custom_payments[params[:date]] = params[:loan][:amount]
      @loan.update_attributes(custom_payments: custom_payments)
      redirect_to loan_path(@loan.id)
    end

    def delete_custom_payment
      @loan = Loan.find(params[:id])
      custom_payments = @loan.custom_payments
      custom_payments.delete(params[:date])
      @loan.update_attributes(custom_payments: custom_payments)
      redirect_to loan_path(@loan.id)
    end

    def show_custom_payment
      @loan = Loan.find(params[:id])
      @custom_payment = @loan.custom_payments[params[:date]]
    end

    def change_date_pointer
      @loan = Loan.find(params[:id])
      @loan.update_attributes(date_pointer: params[:date])
      redirect_to loan_path(@loan.id, scenario: params[:scenario])
    end

    # NOTE: Since number_field does not
    # seem to convert inputs to integer
    def convert_amount_to_integer
      loan_params["actual_events_attributes"]["0"]["data"]["amount"] =
        loan_params["actual_events_attributes"]["0"]["data"]["amount"].to_f
    end

    def convert_custom_payment_amount_to_integer
      params[:loan][:amount] =
        params[:loan][:amount].to_f
    end
  end
end
