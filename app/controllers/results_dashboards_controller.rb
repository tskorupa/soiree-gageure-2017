# frozen_string_literal: true
class ResultsDashboardsController < ApplicationController
  include LotteryLookup

  def index
    @title = set_title

    dropped_off_tickets = @lottery.tickets.where(dropped_off: true)
    return no_tickets_message if dropped_off_tickets.size.zero?

    ordered_tickets = dropped_off_tickets.order(order_by)
    @draw_results = ordered_tickets.map do |ticket|
      ticket.drawn_position ? ticket : nil
    end

    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'results_dashboards/index_header',
        main_header_locals: {},
        main_partial: 'results_dashboards/index',
        main_partial_locals: {},
      },
    )
  end

  private

  def no_tickets_message
    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'results_dashboards/index_header',
        main_header_locals: {},
        main_partial: 'results_dashboards/no_tickets_index',
        main_partial_locals: {},
      },
    )
  end

  def set_title
    variant = if order_by == :number
      'ordered_by_number'
    else
      'ordered_by_drawn_position'
    end

    t(format('results_dashboards.index.title.%s', variant))
  end

  def order_by
    @order_by ||= if params[:order_by] == 'number'
      :number
    else
      :drawn_position
    end
  end
end
