class TicketDrawsController < ApplicationController
  include LotteryLookup

  def index
    @number = params[:number]
    @tickets = if @number.present?
      tickets_for_draw.where(number: @number).order(:number)
    else
      Ticket.none
    end

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'ticket_draws/index' },
    )
  end

  def update
    @ticket = tickets_for_draw.find(params[:id])
    @ticket.update_attributes(
      drawn: true,
      drawn_at: Time.now.utc,
    )
    redirect_to(lottery_ticket_draws_path(@lottery))
  end

  private

  def tickets_for_draw
    @lottery.tickets.where(
      registered: true,
      dropped_off: true,
      drawn: false,
    )
  end
end
