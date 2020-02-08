module Lms
  class ExpectedTransaction < ApplicationRecord
    PRINCIPAL = "principal"
    INTEREST = "interest"

    INIT_PRINCIPAL = "init_principal"
    INIT_INTEREST = "init_interest"

    belongs_to :loan
  end
end
