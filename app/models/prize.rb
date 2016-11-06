class Prize < ApplicationRecord
  belongs_to :lottery

  attr_readonly :lottery_id

  validates :draw_order, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :lottery_id }
  validates :amount, numericality: { greater_than: 0 }
end
