module Lms
  class ActualTransaction < ApplicationRecord
    after_create :balance

    PAYMENT = "payment"

    belongs_to :loan

    def balance
      balancer = Balancer.new(loan, Date.today)
      table, status = balancer.execute

      loan.update_attributes(status: status)
    end
  end
end
