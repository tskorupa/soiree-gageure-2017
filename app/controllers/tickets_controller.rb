class TicketsController < ApplicationController
  before_action :find_lottery

  def index
    @q = params[:q]
    @tickets = TicketSearch
      .new(lottery_id: @lottery.id, query: @q)
      .order(:number)

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'tickets/index' },
    )
  end

  def new
    builder = TicketBuilder.new(lottery: @lottery)
    @ticket = @lottery.tickets.new
  end

  def create
    builder = TicketBuilder.new(lottery: @lottery)
    @ticket = builder.build(builder_params)

    return(render(:new)) unless @ticket.save
    redirect_to(lottery_tickets_path(@lottery))
  end

  def edit
    builder = TicketBuilder.new(lottery: @lottery)
    @ticket = @lottery.tickets.find(params[:id])
  end

  def update
    builder = TicketBuilder.new(lottery: @lottery)
    @ticket = builder.build(builder_params.merge(id: params[:id]))

    return(render(:edit)) unless @ticket.save
    redirect_to(lottery_tickets_path(@lottery))
  end

  private

  def find_lottery
    @lottery = Lottery.find(params[:lottery_id])
  end

  def builder_params
    params.require(:ticket)
      .permit(
        :seller_name,
        :guest_name,
        :sponsor_name,
        :number,
        :state,
        :ticket_type,
      )
  end
end
