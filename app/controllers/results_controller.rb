class ResultsController < ApplicationController
  include LotteryLookup

  def index
    tickets = @lottery.tickets
      .where(
        registered: true,
        dropped_off: true,
        drawn: true,
      ).order(drawn_at: :asc)
    @ticket = tickets.last

    calculator = PrizeCalculator.new(@lottery)
    if positions = calculator.draw_positions
      current_position = tickets.size
      positions.each do |(position, prize)|
        next unless position == current_position
        @prize = prize
      end
    end

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'results/index' },
    )
  end
end
