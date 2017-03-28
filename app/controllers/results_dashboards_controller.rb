class ResultsDashboardsController < ApplicationController
  include LotteryLookup

  def index
    dropped_off_tickets = @lottery.tickets.where(dropped_off: true)
    return no_tickets_message if dropped_off_tickets.size.zero?

    ordered_tickets = dropped_off_tickets.order(order_by)
    @draw_results = ordered_tickets.map do |ticket|
      drawn_ticket = ticket.drawn_position ? ticket : nil
    end

    @title = set_title
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'results_dashboards/index' },
    )
  end

  private

  def no_tickets_message
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'results_dashboards/no_tickets_index' },
    )
  end

  def set_title
    variant = if order_by == :number
      'ordered_by_number'
    else
      'ordered_by_drawn_position'
    end

    t('results_dashboards.index.title.%s' % variant)
  end

  def order_by
    @order_by ||= if params[:order_by] == 'number'
      :number
    else
      :drawn_position
    end
  end
end
