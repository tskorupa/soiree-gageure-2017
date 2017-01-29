class ResultsController < ApplicationController
  include LotteryLookup

  def index
    @ticket = @lottery.tickets
      .where(
        registered: true,
        dropped_off: true,
        drawn: true,
      ).order(drawn_at: :asc).last

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'results/index' },
    )
  end
end
