module Lms
  class ActualTransaction < ApplicationRecord
    after_create :balance_and_calculate_breakdown

    PAYMENT = "payment"

    belongs_to :loan

    def balance_and_calculate_breakdown

    end
  end
end
