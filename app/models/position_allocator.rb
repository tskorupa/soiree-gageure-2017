module PositionAllocator
  extend self

  def allocate_position(lottery:)
    num_drawn_tickets = lottery.tickets
      .where.not(drawn_position: nil)
      .count

    num_drawn_tickets + 1
  end
end
