# frozen_string_literal: true
class ResultsController < ApplicationController
  include LotteryLookup

  def index
    @ticket = @lottery.last_drawn_ticket
    return empty_index unless @ticket

    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'results/index_header',
        main_header_locals: {},
        main_partial: 'results/index',
        main_partial_locals: {},
      },
    )
  end

  private

  def empty_index
    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'results/index_header',
        main_header_locals: {},
        main_partial: 'results/empty_index',
        main_partial_locals: {},
      },
    )
  end
end
