module Lms
  class ActualTransaction < ApplicationRecord
    PAYMENT = "payment"

    belongs_to :loan
  end
end
