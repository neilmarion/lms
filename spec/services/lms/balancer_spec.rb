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
      end

      it "creates expected transactions accordingly in order to balance" do

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
      end

      it "creates expected transactions accordingly in order to balance" do

      end
    end
  end
end
