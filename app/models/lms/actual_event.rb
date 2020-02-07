module Lms
  class ActualTransaction < ApplicationRecord
    belongs_to :loan
  end
end
