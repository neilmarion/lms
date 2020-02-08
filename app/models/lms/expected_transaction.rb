module Lms
  class ExpectedTransaction < ApplicationRecord
    PRINCIPAL = "principal"
    INTEREST = "interest"

    belongs_to :loan
  end
end
