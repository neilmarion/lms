require "rails_helper"

module Lms
  describe LoanStateBuilder do
    let(:start_date) { "2020-03-01" }
    let(:balance_date) { "2020-05-01" }
    let(:loan) do
      Loan.create({
        amount: 100000,
        interest: 0.01,
        period_count: 2,
        start_date: start_date,
        period: "monthly",
      })
    end

    context "null state" do
      it "builds the loan state that will balance on the balance date" do
        service = described_class.new(loan, start_date.to_date)
        result = service.execute
        expect(result[balance_date][:zzz_bal].round(2)).to eq 0
      end
    end
  end
end
