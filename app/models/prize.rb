class Prize < ApplicationRecord
  belongs_to :lottery, required: true

  attr_readonly :lottery_id

  validates :draw_order, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :lottery_id }
  validates(
    :amount,
    numericality: { greater_than: 0, less_than: 10_000 },
  )
end
