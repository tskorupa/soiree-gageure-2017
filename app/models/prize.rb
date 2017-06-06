# frozen_string_literal: true

class Prize < ApplicationRecord
  belongs_to :lottery
  belongs_to :ticket, optional: true

  attr_readonly :lottery_id

  validates(
    :draw_order,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :lottery_id },
  )
  validates(
    :nth_before_last,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    uniqueness: { scope: :lottery_id },
    allow_blank: true,
  )
  validates(
    :amount,
    numericality: { greater_than: 0, less_than: 10_000 },
  )
end
