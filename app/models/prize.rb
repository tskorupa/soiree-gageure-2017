class Prize < ApplicationRecord
  belongs_to :lottery

  validates :draw_order, numericality: { only_integer: true, greater_than: 0 }
  validates :amount, numericality: { greater_than: 0 }
end
