# frozen_string_literal: true
class ResultsIndex
  extend Memoist

  def initialize(lottery:)
    @lottery = lottery
  end

  delegate :id, to: :lottery, prefix: :lottery

  def title
    I18n.t 'results.index.title'
  end

  def ticket_to_display?
    !last_drawn_ticket.nil?
  end
  memoize :ticket_to_display?

  def ticket
    return unless ticket_to_display?
    LastDrawnTicket.new(ticket: last_drawn_ticket)
  end
  memoize :ticket

  def no_ticket_message
    I18n.t 'results.index.no_drawn_tickets'
  end

  private

  attr_reader :lottery

  def last_drawn_ticket
    lottery.last_drawn_ticket
  end
end
