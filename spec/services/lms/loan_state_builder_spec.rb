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
      let(:current_date) { start_date }
      it "builds the loan state that will balance on the balance date" do
        service = described_class.new(loan, start_date.to_date)
        result = service.execute
        expect(result[balance_date][:zzz_bal].round(2)).to eq 0
      end
    end

    context "when customer pays off everything on time" do
      let(:current_date) { "2020-05-02" }
      before(:each) do
        loan.actual_transactions.create({
          amount: loan.expected_payment_per_period,
          created_at: "2020-04-01"
        })
        loan.actual_transactions.create({
          amount: loan.expected_payment_per_period,
          created_at: "2020-05-01"
        })
      end

      it "builds the loan state that will balance on the balance date" do
        service = described_class.new(loan, current_date)
        result = service.execute
        expect(result[balance_date][:zzz_bal].round(2)).to eq 0
      end
    end
  end
end
