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
        builder = service.execute
        result = builder.execute
        expect(result[balance_date][:zzz_bal].round(2)).to eq 0
      end
    end

    context "when customer pays off everything on time" do
      let(:current_date) { "2020-05-02" }
      before(:each) do
        loan.actual_transactions.create({
          amount: -1*loan.expected_payment_per_period,
          created_at: "2020-04-01"
        })
        loan.actual_transactions.create({
          amount: -1*loan.expected_payment_per_period,
          created_at: "2020-05-01"
        })
      end

      it "builds the loan state that will balance on the balance date" do
        service = described_class.new(loan, current_date)
        builder = service.execute
        result = builder.execute
        expect(result[balance_date][:zzz_bal].round(2)).to eq 0
      end
    end

    context "when customer pays late but pays additional interest" do
      let(:current_date) { "2020-04-13" }
      before(:each) do
        loan.actual_transactions.create({
          amount: -1*loan.expected_payment_per_period,
          created_at: "2020-04-12",
          updated_at: "2020-04-12",
        })
        # NOTE: This is pre-computed
        loan.actual_transactions.create({
          amount: -183.58,
          kind: "payment",
          created_at: "2020-04-12",
          updated_at: "2020-04-12",
        })
        loan.actual_transactions.create({
          amount: -1*loan.expected_payment_per_period,
          created_at: "2020-05-01",
          updated_at: "2020-05-01",
        })
      end

      it "builds the loan state that will balance on the balance date" do
        service = described_class.new(loan, current_date)
        builder = service.execute
        result = builder.execute
        expect(result[balance_date][:zzz_bal].round(2)).to eq 0
      end
    end

    context "when customer pays early so lesser interest is paid" do
      let(:current_date) { "2020-05-02" }
      before(:each) do
        loan.actual_transactions.create({
          amount: -1*80000,
          created_at: "2020-04-01",
          updated_at: "2020-04-01",
        })
        loan.actual_transactions.create({
          amount: -1*21210,
          created_at: "2020-05-01",
          updated_at: "2020-05-01",
        })
      end

      # NOTE: balance was 101,502 but now it's only 101,210
      it "builds the loan state that will balance on the balance date" do
        service = described_class.new(loan, current_date)
        builder = service.execute
        result = builder.execute
        expect(result[balance_date][:zzz_bal].round(2)).to eq 0
      end
    end
  end
end
