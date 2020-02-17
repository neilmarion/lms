module Lms
  class ActualTransaction < ApplicationRecord
    PAYMENT = "payment"
    WAIVE = "waive"

    belongs_to :loan
  end
end
