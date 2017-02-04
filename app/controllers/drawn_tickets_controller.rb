class DrawnTicketsController < ApplicationController
  include LotteryLookup

  def index
    @tickets = drawn_tickets.order(drawn_at: :desc)
    @tickets_count = @tickets.count
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

  def drawn_tickets
    @lottery.tickets.where(drawn: true)
  end
end
