# frozen_string_literal: true
class TicketDrawsController < ApplicationController
  include LotteryLookup

  def index
    @ticket_listing = TicketListing.new(
      ticket_scope: @lottery.drawable_tickets,
      number_filter: params[:number_filter],
    )
  end

  def update
    return head(:no_content) unless @lottery.locked?

    ticket = @lottery.drawable_tickets.find(params[:id])
    @lottery.draw(ticket: ticket)

    redirect_to(lottery_ticket_draws_path(@lottery))
  end
end
