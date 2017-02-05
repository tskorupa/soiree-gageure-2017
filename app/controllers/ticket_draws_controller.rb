class TicketDrawsController < ApplicationController
  include LotteryLookup

  def index
    @number = params[:number]
    @tickets = tickets_for_draw.order(:number)
    @tickets = @tickets.where(number: @number) if @number.present?

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'ticket_draws/index' },
    )
  end

  def update
    return head(:no_content) unless @lottery.locked?

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
      dropped_off: true,
      drawn: false,
    )
  end
end
