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

    context "when customer pays on time" do
      before(:each) do
        loan.actual_transactions.create({
          amount: -1*loan.expected_payment_per_period,
          created_at: "2020-04-01"
        })
      end

      it "creates expected transactions accordingly in order to balance" do
        expected_txns_count = loan.expected_transactions.count
        expect {
          balancer = described_class.new(loan, "2020-04-01".to_date)
          balancer.execute
          expected_txns_count = loan.expected_transactions.count
        }.not_to change{ expected_txns_count }.from 4
      end
    end

    context "when customer pays late but pays additional interest" do
      let(:current_date) { "2020-04-06" }
      it "creates expected transactions accordingly in order to balance" do
        expected_txns_count = loan.expected_transactions.count
        expect {
          balancer = described_class.new(loan, current_date.to_date)
          balancer.execute
          expected_txns_count = loan.expected_transactions.count
        }.to change{ expected_txns_count }.from 4

        # NOTE: No more expected transactions must be created after balancing
        expect {
          balancer = described_class.new(loan, current_date.to_date)
          balancer.execute
          expected_txns_count = loan.expected_transactions.count
        }.not_to change{ expected_txns_count }.from 5
      end
    end

    context "when customer pays early so lesser interest is paid" do
      let(:current_date) { "2020-04-02" }
      before(:each) do
        loan.actual_transactions.create({
          amount: -1*80000,
          created_at: "2020-04-01",
          updated_at: "2020-04-01",
        })
      end

      it "creates expected transactions accordingly in order to balance" do
        expected_txns_count = loan.expected_transactions.count
        expect {
          balancer = described_class.new(loan, current_date.to_date)
          balancer.execute
          expected_txns_count = loan.expected_transactions.count
        }.to change{ expected_txns_count }.from 4

        # NOTE: No more expected transactions must be created after balancing
        expect {
          balancer = described_class.new(loan, current_date.to_date)
          balancer.execute
          expected_txns_count = loan.expected_transactions.count
        }.not_to change{ expected_txns_count }.from 6
      end
    end
  end
end
