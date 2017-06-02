# frozen_string_literal: true

class Seller < ApplicationRecord
  before_validation(:clean_full_name)
  validates(:full_name, presence: true)

  private

  def clean_full_name
    self.full_name = FullNameFormatter.format(full_name)
  end
end
