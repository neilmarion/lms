module Lms
  class ExpectedTransaction < ApplicationRecord
    PRINCIPAL = "principal"
    INTEREST = "interest"
    INTEREST_FEE = "interest_fee"

    INIT_PRINCIPAL = "init_principal"
    INIT_INTEREST = "init_interest"

    belongs_to :loan
  end
end
