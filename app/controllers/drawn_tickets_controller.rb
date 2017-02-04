class DrawnTicketsController < ApplicationController
  include LotteryLookup

  def index
    num_participating_tickets = @lottery.tickets.where(dropped_off: true).count
    return no_tickets_message if num_participating_tickets.zero?

    positions = (1..num_participating_tickets).to_a
    tickets = drawn_tickets.order(:drawn_at)
    @draw_positions = positions.zip(tickets)

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'drawn_tickets/index' },
    )
  end

  def update
    @ticket = drawn_tickets.find(params[:id])
    @ticket.update_attributes(
      drawn: false,
      drawn_at: nil,
    )
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
    @lottery.tickets.where(drawn: true)
  end
end
