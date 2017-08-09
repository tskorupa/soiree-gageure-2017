# frozen_string_literal: true
class TicketRegistrationsController < ApplicationController
  include LotteryLookup

  def index
    @ticket_listing = TicketListing.new(
      ticket_scope: @lottery.registerable_tickets,
      number_filter: params[:number_filter],
    )

    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'tickets/ticket_listing_header',
        main_header_locals: {
          title: t('ticket_registrations.index.title'),
          path_to_listing: lottery_ticket_registrations_path(@lottery),
          can_build_new: false,
        },
        main_partial: main_partial,
        main_partial_locals: { message: main_partial_message },
      },
    )
  end

  def edit
    raise(ArgumentError, 'Lottery is locked') if @lottery.locked?
    @ticket = @lottery.registerable_tickets.find(params[:id])
  end

  def update
    raise(ArgumentError, 'Lottery is locked') if @lottery.locked?

    ticket = @lottery.registerable_tickets.find(params[:id])

    @builder = TicketBuilder.new(lottery: @lottery)
    @ticket = @builder.build(builder_params.merge(id: ticket.id))
    return render(:edit) unless @ticket.can_be_registered?

    @ticket.register
    redirect_to(lottery_ticket_registrations_path(@lottery))
  end

  private

  def builder_params
    params.permit(
      :guest_name,
      :table_number,
    )
  end

  def main_partial
    return 'ticket_registrations/ticket_listing' if @ticket_listing.tickets_to_display?
    'tickets/empty_ticket_listing'
  end

  def main_partial_message
    if no_tickets_to_display_for_number?
      t(
        'ticket_registrations.index.no_tickets_with_number',
        number_filter: @ticket_listing.number_filter,
      )
    else
      t('ticket_registrations.index.no_tickets')
    end
  end

  def no_tickets_to_display_for_number?
    !@ticket_listing.tickets_to_display? && @ticket_listing.number_filter.present?
  end
end
