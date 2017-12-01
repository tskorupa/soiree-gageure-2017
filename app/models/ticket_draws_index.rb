# frozen_string_literal: true
class TicketDrawsIndex < TicketListing
  def initialize(lottery:, number_filter:)
    @lottery = lottery
    super(
      ticket_scope: lottery.drawable_tickets,
      number_filter: number_filter,
    )
  end

  def prize_for_next_drawn_ticket?
    !prize_for_next_drawn_ticket.nil?
  end

  def prize_for_next_drawn_ticket
    prize_amount = lottery.next_prize_amount
    return unless prize_amount

    formatted_amount = ActiveSupport::NumberHelper.number_to_currency(prize_amount)
    I18n.t('ticket_draws.index.prize_for_next_drawn_ticket', amount: formatted_amount)
  end
  memoize :prize_for_next_drawn_ticket

  private

  attr_reader :lottery
end
