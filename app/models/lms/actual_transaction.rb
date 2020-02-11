module Lms
  class ActualTransaction < ApplicationRecord
    after_create :do_balance

    PAYMENT = "payment"
    WAIVE = "waive"

    belongs_to :loan

    def do_balance
      balancer = Balancer.new(loan, loan.date_today || Date.today)
      balancer.execute
    end
  end
end
