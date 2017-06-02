# frozen_string_literal: true

class Table < ApplicationRecord
  belongs_to :lottery, required: true
  has_many :tickets

  attr_readonly :lottery_id

  validates :number, :capacity, numericality: { only_integer: true, greater_than: 0 }
  validates :number, uniqueness: { scope: :lottery_id }
end
