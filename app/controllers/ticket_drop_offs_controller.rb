# frozen_string_literal: true
class TicketDropOffsController < ApplicationController
  include LotteryLookup

  def index
    @ticket_listing = TicketListing.new(
      ticket_scope: @lottery.droppable_tickets,
      number_filter: params[:number_filter],
    )
  end

  def update
    return head(:no_content) if @lottery.locked?

    @ticket = @lottery.droppable_tickets.find(params[:id])
    @ticket.update_attributes(dropped_off: true)
    redirect_to(lottery_ticket_drop_offs_path(@lottery))
  end
end
