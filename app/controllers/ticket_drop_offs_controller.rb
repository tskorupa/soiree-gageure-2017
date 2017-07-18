# frozen_string_literal: true

class TicketDropOffsController < ApplicationController
  include LotteryLookup

  def index
    @number = params[:number]
    @tickets = @lottery.droppable_tickets.includes(:guest).order(:number)
    @tickets = @tickets.where(number: @number) if @number.present?

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'ticket_drop_offs/index' },
    )
  end

  def update
    return head(:no_content) if @lottery.locked?

    @ticket = @lottery.droppable_tickets.find(params[:id])
    @ticket.update_attributes(dropped_off: true)
    redirect_to(lottery_ticket_drop_offs_path(@lottery))
  end
end
