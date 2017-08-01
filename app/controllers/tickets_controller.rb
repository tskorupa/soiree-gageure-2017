# frozen_string_literal: true
class TicketsController < ApplicationController
  include LotteryLookup

  def index
    @ticket_listing = TicketListing.new(
      ticket_scope: @lottery.tickets,
      number_filter: params[:number_filter],
    )

    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'tickets/ticket_listing_header',
        main_header_locals: {
          title: Ticket.model_name.human.pluralize.titleize,
          path_to_listing: lottery_tickets_path(@lottery),
          can_build_new: true,
        },
        main_partial: main_partial,
        main_partial_locals: { message: main_partial_message },
      },
    )
  end

  def new
    @ticket = @lottery.tickets.new
  end

  def create
    builder = TicketBuilder.new(lottery: @lottery)
    @ticket = builder.build(builder_params)

    return(render(:new)) if @ticket.errors.any?
    @ticket.save!
    redirect_to(lottery_tickets_path(@lottery))
  end

  def edit
    @ticket = @lottery.tickets.find(params[:id])
  end

  def update
    @builder = TicketBuilder.new(lottery: @lottery)
    @ticket = @builder.build(builder_params.merge(id: params[:id]))

    return(render(:edit)) if @ticket.errors.any?
    @ticket.save!
    redirect_to(lottery_tickets_path(@lottery))
  end

  private

  def builder_params
    ticket_params = params.fetch(:ticket, {})
      .permit(
        :number,
        :state,
        :ticket_type,
      )

    params.permit(
      :seller_name,
      :guest_name,
      :sponsor_name,
      :table_number,
    ).merge(ticket_params.to_h)
  end

  def main_partial
    return 'tickets/ticket_listing' if @ticket_listing.tickets_to_display?
    'tickets/empty_ticket_listing'
  end

  def main_partial_message
    if no_tickets_to_display_for_number?
      t(
        'tickets.index.no_tickets_with_number',
        number_filter: @ticket_listing.number_filter,
      )
    else
      t('tickets.index.no_tickets')
    end
  end

  def no_tickets_to_display_for_number?
    !@ticket_listing.tickets_to_display? && @ticket_listing.number_filter.present?
  end
end
