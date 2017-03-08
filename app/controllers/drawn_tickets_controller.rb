class DrawnTicketsController < ApplicationController
  include LotteryLookup

  def index
    dropped_off_tickets_count = @lottery.tickets.where(dropped_off: true).count
    return no_tickets_message if dropped_off_tickets_count.zero?

    @draw_results = DrawResultsListing.draw_results(
      drawn_tickets: drawn_tickets,
      prizes: @lottery.prizes,
      dropped_off_tickets_count: dropped_off_tickets_count,
    )
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'drawn_tickets/index' },
    )
  end

  def update
    @ticket = drawn_tickets.includes(:lottery).find(params[:id])
    DrawnTicketUpdater.update(ticket: @ticket)
    redirect_to(lottery_drawn_tickets_path(@lottery))
  end

  private

  def no_tickets_message
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'drawn_tickets/no_tickets_index' },
    )
  end

  def drawn_tickets
    @lottery.tickets.where.not(drawn_position: nil)
  end
end
