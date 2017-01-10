class Ticket < ApplicationRecord
  STATES = %w(reserved authorized paid).map(&:freeze).freeze
  TICKET_TYPES = %w(meal_and_lottery lottery_only).map(&:freeze).freeze

  belongs_to :lottery, required: true
  belongs_to :seller
  belongs_to :guest
  belongs_to :sponsor
  belongs_to(
    :table,
    -> (ticket) { where(lottery_id: ticket.lottery_id) },
    counter_cache: true,
  )

  attr_readonly :lottery_id

  validates :ticket_type, inclusion: { in: TICKET_TYPES }
  validates :number, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :lottery_id }
  validates :state, inclusion: { in: STATES }
  validate :table_must_be_present_when_table_id_is_given

  private

  def table_must_be_present_when_table_id_is_given
    return if table_id.nil? || table
    self.errors.add(:table_id, :invalid)
  end
end
