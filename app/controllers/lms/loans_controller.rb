module Lms
  class LoansController < ApplicationController
    before_filter :convert_amount_to_integer, only: [:update]

    def show
      @loan = Loan.find(params[:id])
      @current_scenario = @loan.current_scenario(params[:scenario])
    end

    def update
      @loan = Loan.find(params[:id])
      @loan.update_attributes(loan_params)
      redirect_to loan_path(@loan.id)
    end

    def loan_params
      @loan_params ||= params.require(:loan).permit(
        actual_events_attributes: [{data: :amount}, :date, :name],
      )
    end

    # NOTE: Since number_field does not
    # seem to convert inputs to integer
    def convert_amount_to_integer
      loan_params["actual_events_attributes"]["0"]["data"]["amount"] =
        loan_params["actual_events_attributes"]["0"]["data"]["amount"].to_f
    end
  end
end
