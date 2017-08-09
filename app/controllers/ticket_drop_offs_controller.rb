# frozen_string_literal: true
class TicketDropOffsController < ApplicationController
  include LotteryLookup

  def index
    @ticket_listing = TicketListing.new(
      ticket_scope: @lottery.droppable_tickets,
      number_filter: params[:number_filter],
    )

    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'tickets/ticket_listing_header',
        main_header_locals: {
          title: t('ticket_drop_offs.index.title'),
          path_to_listing: lottery_ticket_drop_offs_path(@lottery),
          can_build_new: false,
        },
        main_partial: main_partial,
        main_partial_locals: { message: main_partial_message },
      },
    )
  end

  def update
    return head(:no_content) if @lottery.locked?

    @ticket = @lottery.droppable_tickets.find(params[:id])
    @ticket.update_attributes(dropped_off: true)
    redirect_to(lottery_ticket_drop_offs_path(@lottery))
  end

  private

  def main_partial
    return 'ticket_drop_offs/ticket_listing' if @ticket_listing.tickets_to_display?
    'tickets/empty_ticket_listing'
  end

  def main_partial_message
    if no_tickets_to_display_for_number?
      t(
        'ticket_drop_offs.index.no_tickets_with_number',
        number_filter: @ticket_listing.number_filter,
      )
    else
      t('ticket_drop_offs.index.no_tickets')
    end
  end

  def no_tickets_to_display_for_number?
    !@ticket_listing.tickets_to_display? && @ticket_listing.number_filter.present?
  end
end
