# frozen_string_literal: true

class Ticket < ApplicationRecord
  STATES = %w(reserved authorized paid).freeze
  TICKET_TYPES = %w(meal_and_lottery lottery_only).freeze

  belongs_to :lottery
  belongs_to :seller, optional: true
  belongs_to :guest, optional: true
  belongs_to :sponsor, optional: true
  belongs_to :table, optional: true, counter_cache: true

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
