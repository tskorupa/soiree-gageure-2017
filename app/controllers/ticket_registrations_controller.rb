# frozen_string_literal: true
class TicketRegistrationsController < ApplicationController
  include LotteryLookup

  def index
    tickets = @lottery.registerable_tickets
    number_filter = params[:number_filter]

    @ticket_listing = TicketRegistrationsIndex.new(
      tickets: tickets,
      number_filter: number_filter,
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
end
