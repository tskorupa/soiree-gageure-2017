class Seller < ApplicationRecord
  has_many :tickets

  before_validation(:clean_full_name)
  validates(:full_name, presence: true)

  private

  def clean_full_name
    self.full_name = full_name.to_s.strip.squeeze(' ').titleize
  end
end
