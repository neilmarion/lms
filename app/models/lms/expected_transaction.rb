module Lms
  class ExpectedTransaction < ApplicationRecord
    INITIAL_BALANCE = "initial_balance"

    belongs_to :loan
  end
end
