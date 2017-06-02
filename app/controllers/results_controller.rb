# frozen_string_literal: true

class ResultsController < ApplicationController
  include LotteryLookup

  def index
    @ticket = @lottery.last_drawn_ticket
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
