# frozen_string_literal: true
class TicketsDashboard
  def initialize(lottery:)
    @lottery = lottery
  end

  def total_tickets_count
    lottery.tickets.count
  end

  def reserved_tickets_count
    lottery.reserved_tickets.count
  end

  def registerable_tickets_count
    lottery.registerable_tickets.count
  end

  def droppable_tickets_count
    lottery.droppable_tickets.count
  end

  def drawable_tickets_count
    lottery.drawable_tickets.count
  end

  def drawn_tickets_count
    lottery.drawn_tickets.count
  end

  private

  attr_reader :lottery
end
