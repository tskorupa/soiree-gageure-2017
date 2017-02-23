class Ticket < ApplicationRecord
  STATES = %w(reserved authorized paid).map(&:freeze).freeze
  TICKET_TYPES = %w(meal_and_lottery lottery_only).map(&:freeze).freeze

  belongs_to :lottery, required: true
  belongs_to :seller
  belongs_to :guest
  belongs_to :sponsor
  belongs_to :table, counter_cache: true

  has_one :prize

  attr_readonly :lottery_id

  validates :ticket_type, inclusion: { in: TICKET_TYPES }
  validates(
    :number,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :lottery_id },
  )
  validates :state, inclusion: { in: STATES }
  validates(
    :drawn_position,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :lottery_id },
    allow_blank: true,
  )
end
