class Lottery < ApplicationRecord
  has_many :prizes
  has_many :tables
  has_many :tickets

  validates :event_date, presence: true
  validates :ticket_price, :meal_voucher_price, numericality: { greater_than: 0 }, allow_nil: true
end
