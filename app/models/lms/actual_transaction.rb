module Lms
  class ActualTransaction < ApplicationRecord
    after_create :calculate_breakdown

    PAYMENT = "payment"

    belongs_to :loan

    def calculate_breakdown

    end
  end
end
