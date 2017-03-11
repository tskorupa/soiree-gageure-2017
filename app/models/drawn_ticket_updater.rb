module DrawnTicketUpdater
  extend self

  def update(lottery:)
    ticket = lottery.last_drawn_ticket
    return unless ticket

    prize = lottery.prizes.find_by(ticket_id: ticket.id)

    Ticket.connection.transaction do
      prize.update!(ticket_id: nil) if prize
      ticket.update!(drawn_position: nil)
    end

    DrawnTicketBroadcastJob.perform_later(lottery_id: lottery.id)
  end
end
