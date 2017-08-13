# frozen_string_literal: true
class ResultRow
  extend Memoist

  def initialize(position:, ticket:, prize_amount:)
    @position = position
    @ticket = ticket
    @prize_amount = prize_amount
  end

  attr_reader :position, :prize_amount

  def ticket_to_display?
    ticket.present?
  end

  def ticket_number
    return unless ticket
    PaddedNumber.pad_number(ticket.number)
  end
  memoize :ticket_number

  def guest_name
    ticket&.guest&.full_name
  end
  memoize :guest_name

  delegate :model_name, to: :ticket
  def to_param
    ticket.id
  end

  private

  attr_reader :ticket
end
