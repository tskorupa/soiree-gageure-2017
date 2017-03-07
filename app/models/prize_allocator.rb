module PrizeAllocator
  extend self

  def allocate_prize(lottery:, position:)
    num_tickets_in_draw = lottery.tickets.where(dropped_off: true).count

    nth_before_last = if position == 1
      nil
    else
      num_tickets_in_draw - position
    end

    lottery.prizes.find_by(nth_before_last: nth_before_last)
  end
end
