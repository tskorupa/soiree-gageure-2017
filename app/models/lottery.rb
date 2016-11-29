class Lottery < ApplicationRecord
  has_many :prizes
  has_many :tables
  has_many :tickets, inverse_of: :lottery

  validates :event_date, presence: true
  validates(
    :ticket_price,
    :meal_voucher_price,
    numericality: { greater_than: 0, less_than: 10_000 },
    allow_nil: true,
  )
end
