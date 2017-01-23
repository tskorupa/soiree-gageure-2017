class ResultsController < ApplicationController
  before_action :find_lottery

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

  private

  def find_lottery
    @lottery = Lottery.find(params[:lottery_id])
  end
end
