module Lms
  module Loans
    class ActualEventsController < ApplicationController
      before_filter :get_loan

      def new
      end

      def index
        @actual_events = @loan.actual_events.where(date: params[:date])
      end

      def destroy
        @loan.actual_events.find_by(id: params[:id]).destroy
        redirect_to loan_path(@loan.id)
      end

      def get_loan
        @loan = Lms::Loan.find(params[:loan_id])
      end
    end
  end
end
