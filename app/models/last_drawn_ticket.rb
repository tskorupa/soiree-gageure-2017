# frozen_string_literal: true
class LastDrawnTicket
  extend Memoist

  def initialize(ticket:)
    @ticket = ticket
  end

  delegate :lottery_id, to: :ticket

  def guest_name
    ticket.guest&.full_name
  end
  memoize :guest_name

  def number
    padded_number = PaddedNumber.pad_number(ticket.number)

    format(
      '%s %s',
      Ticket.model_name.human,
      padded_number,
    )
  end
  memoize :number

  def ticket_type
    return unless ticket.ticket_type == 'lottery_only'

    format('ticket_type.%s', ticket.ticket_type)
  end
  memoize :ticket_type

  def table_number
    return unless ticket.ticket_type == 'meal_and_lottery'

    number = ticket.table&.number
    return unless number

    format(
      '%s %s',
      Table.model_name.human,
      number,
    )
  end
  memoize :table_number

  def prize_amount
    prize = ticket.prize
    return unless prize

    format(
      '%s %s',
      Prize.model_name.human,
      ActiveSupport::NumberHelper.number_to_currency(prize.amount),
    )
  end
  memoize :prize_amount

  private

  attr_reader :ticket
end
