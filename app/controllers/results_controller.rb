class ResultsController < ApplicationController
  include LotteryLookup

  def index
    @ticket = @lottery.tickets
      .includes(:prize)
      .where.not(drawn_position: nil)
      .order(:drawn_position)
      .last
    return empty_index unless @ticket

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'results/index' },
    )
  end

  private

  def empty_index
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'results/empty_index' },
    )
  end
end
