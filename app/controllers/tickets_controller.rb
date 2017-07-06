# frozen_string_literal: true

class TicketsController < ApplicationController
  include LotteryLookup

  def index
    @q = params[:q]
    @tickets = @lottery.tickets.includes(:seller, :guest, :sponsor, :table).order(:number)
    @tickets = @tickets.where(id: @q) if @q.present?

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'tickets/index' },
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
end
