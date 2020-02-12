require "rails_helper"

module Lms
  describe Balancer do
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

    context "when customer is on time" do
      let(:current_date) { "2020-04-02" }
      before(:each) do
        loan.actual_transactions.create({
          amount: -1*loan.expected_payment_per_period,
          created_at: "2020-04-01"
        })
      end

      specify do
        balancer = described_class.new(loan, current_date.to_date)
        table, result = balancer.execute
        expect(result).to eq "ontime"
      end
    end

    context "when customer is late" do
      let(:current_date) { "2020-04-02" }

      specify do
        allow(Date).to receive(:today).and_return(current_date.to_date)
        balancer = described_class.new(loan, current_date.to_date)
        table, result = balancer.execute
        expect(result).to eq "late"
      end
    end

    context "when customer pays early" do
      let(:current_date) { "2020-04-02" }
      before(:each) do
        loan.actual_transactions.create({
          amount: -1*80000,
          created_at: "2020-04-01",
          updated_at: "2020-04-01",
        })
      end

      specify do
        allow(Date).to receive(:today).and_return(current_date.to_date)
        balancer = described_class.new(loan, current_date.to_date)
        table, result = balancer.execute
        expect(result).to eq "early"
      end
    end
  end
end
