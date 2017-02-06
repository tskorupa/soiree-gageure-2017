class PrizeCalculator
  def initialize(lottery)
    @lottery = lottery
  end

  def draw_positions
    return if prizes_count.zero?
    return if num_prizes_to_compute < 0

    positions = [
      1,
      *winning_positions,
      tenth_to_last_position,
      num_tickets,
    ].uniq

    prizes = lottery.prizes.order(:draw_order)
    positions.map.with_index do |position, index|
      amount = prizes[index]&.amount
      [position, amount]
    end
  end

  private

  attr_reader(
    :lottery,
    :prizes_count,
    :num_prizes_to_compute,
    :gap_between_prizes,
    :tenth_to_last_position,
    :num_tickets,
  )

  def prizes_count
    @prizes_count ||= lottery.prizes.count
  end

  def num_prizes_to_compute
    @num_prizes_to_compute ||= prizes_count - 2
  end

  def winning_positions
    (2..num_prizes_to_compute).map do |prize|
      (prize - 1) * gap_between_prizes + 1
    end
  end

  def gap_between_prizes
    @gap_between_prizes ||= tenth_to_last_position / num_prizes_to_compute
  end

  def tenth_to_last_position
    @tenth_to_last_position ||= num_tickets - 9
  end

  def num_tickets
    @num_tickets ||= lottery.tickets.where(dropped_off: true).count
  end
end
