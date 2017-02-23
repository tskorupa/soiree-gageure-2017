class ResultsController < ApplicationController
  include LotteryLookup

  def index
    @ticket = @lottery.tickets
      .includes(:prize)
      .where.not(drawn_position: nil)
      .order(:drawn_position)
      .last

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'results/index' },
    )
  end
end
