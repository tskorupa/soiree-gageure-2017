# frozen_string_literal: true
class ResultsListing
  extend Memoist
  include Enumerable

  def initialize(lottery:)
    @lottery = lottery
  end

  def tickets_to_display?
    !num_rows_to_display.zero?
  end

  def each
    num_rows_to_display.times do |index|
      position = index + 1
      ticket = drawn_tickets[index]
      amount = prize_amount(position)

      yield ResultRow.new(
        position: position,
        ticket: ticket,
        prize_amount: amount,
      )
    end
  end

  private

  attr_reader :lottery

  def num_rows_to_display
    lottery.tickets
      .where(dropped_off: true)
      .count
  end
  memoize :num_rows_to_display

  def drawn_tickets
    lottery.drawn_tickets
      .includes(:guest)
      .order(:drawn_position)
  end
  memoize :drawn_tickets

  def prize_amount(position)
    prize = case position
    when 1
      first_announced_prize
    when num_rows_to_display
      grand_prize
    else
      consolation_prize(position)
    end

    prize&.amount
  end

  def first_announced_prize
    lottery.prizes.find_by(nth_before_last: nil)
  end

  def consolation_prize(row_number)
    nth_before_last = (num_rows_to_display - row_number).abs
    lottery.prizes.find_by(nth_before_last: nth_before_last)
  end

  def grand_prize
    lottery.prizes.find_by(nth_before_last: 0)
  end
end
