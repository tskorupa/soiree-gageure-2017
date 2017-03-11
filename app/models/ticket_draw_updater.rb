class TicketDrawUpdater
  def initialize(ticket:)
    @ticket = ticket
  end

  def update
    lottery = ticket.lottery
    position = PositionAllocator.allocate_position(lottery: lottery)
    prize = PrizeAllocator.allocate_prize(lottery: lottery, position: position)

    Ticket.connection.transaction do
      prize.update!(ticket: ticket) if prize
      ticket.update!(drawn_position: position)
    end

    DrawnTicketBroadcastJob.perform_later(lottery_id: lottery.id)
  end

  private

  attr_reader :ticket
end
