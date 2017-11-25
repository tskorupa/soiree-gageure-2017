# frozen_string_literal: true
class LastDrawnTicket
  extend Memoist

  def initialize(ticket:)
    @ticket = ticket
  end

  delegate :guest_name, to: :ticket

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

    Ticket.human_attribute_name('ticket_type.lottery_only')
  end
  memoize :ticket_type

  def table_number
    return unless ticket.table_number

    format(
      '%s %s',
      Table.model_name.human,
      ticket.table_number,
    )
  end
  memoize :table_number

  def prize_to_display?
    !ticket.prize_amount.nil?
  end

  def prize_amount
    return unless prize_to_display?

    format(
      '%s %s',
      Prize.model_name.human,
      ActiveSupport::NumberHelper.number_to_currency(ticket.prize_amount),
    )
  end
  memoize :prize_amount

  private

  attr_reader :ticket
end
