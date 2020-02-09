module Lms
  class ActualTransaction < ApplicationRecord
    after_create :do_balance

    PAYMENT = "payment"

    belongs_to :loan

    def do_balance
      balancer = Balancer.new(loan, Date.today)
      table, status = balancer.execute

      loan.update_attributes(status: status)
    end
  end
end
