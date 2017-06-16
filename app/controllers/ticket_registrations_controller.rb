# frozen_string_literal: true

class TicketRegistrationsController < ApplicationController
  include LotteryLookup

  def index
    @number = params[:number]
    @tickets = @lottery.registerable_tickets.includes(:guest, :table).order(:number)
    @tickets = @tickets.where(number: @number) if @number.present?

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'ticket_registrations/index' },
    )
  end

  def edit
    raise(ArgumentError, 'Lottery is locked') if @lottery.locked?
    @ticket = @lottery.registerable_tickets.find(params[:id])
  end

  def update
    raise(ArgumentError, 'Lottery is locked') if @lottery.locked?

    @builder = TicketBuilder.new(lottery: @lottery)
    ticket = @lottery.registerable_tickets.find(params[:id])

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
