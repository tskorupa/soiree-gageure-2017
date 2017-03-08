module DrawnTicketUpdater
  extend self

  def update(ticket:)
    lottery = ticket.lottery
    prize = lottery.prizes.find_by(ticket_id: ticket.id)

    Ticket.connection.transaction do
      prize.update!(ticket_id: nil) if prize
      ticket.update!(drawn_position: nil)
    end
  end
end
