# frozen_string_literal: true

class TicketDrawsController < ApplicationController
  include LotteryLookup

  def index
    @number = params[:number]
    @tickets = @lottery.drawable_tickets.includes(:guest).order(:number)
    @tickets = @tickets.where(number: @number) if @number.present?

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'ticket_draws/index' },
    )
  end

  def update
    return head(:no_content) unless @lottery.locked?

    ticket = @lottery.drawable_tickets.find(params[:id])
    @lottery.draw(ticket: ticket)

    redirect_to(lottery_ticket_draws_path(@lottery))
  end
end
