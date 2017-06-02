# frozen_string_literal: true

module DrawResultsListing
  extend self

  def draw_results(prizes:, drawn_tickets:, dropped_off_tickets_count:)
    return unless dropped_off_tickets_count.positive?

    positions = (1..dropped_off_tickets_count).to_a
    results = positions.zip(drawn_tickets.order(:drawn_position))

    prizes.each do |prize|
      index = winning_position(prize, dropped_off_tickets_count) - 1
      next if index.negative?
      next unless results[index]
      results[index] << prize.amount
    end

    results
  end

  private

  attr_reader :lottery

  def winning_position(prize, dropped_off_tickets_count)
    nth_before_last = prize.nth_before_last
    return 1 if nth_before_last.nil?

    dropped_off_tickets_count - nth_before_last
  end
end
