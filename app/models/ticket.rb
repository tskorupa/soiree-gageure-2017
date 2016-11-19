class Ticket < ApplicationRecord
  STATES = %w(reserved authorized sold).map(&:freeze).freeze
  TICKET_TYPES = %w(meal_and_lottery lottery_only).map(&:freeze).freeze

  belongs_to :lottery
  belongs_to :seller
  belongs_to :guest, optional: true
  belongs_to :sponsor, optional: true

  attr_readonly :lottery_id

  validates :ticket_type, inclusion: { in: TICKET_TYPES }
  validates :number, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :lottery_id }
  validates :state, inclusion: { in: STATES }
end
