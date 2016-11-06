class TicketsController < ApplicationController
  before_action :find_lottery

  def index
    @tickets = @lottery.tickets.order(:number)
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'tickets/index' },
    )
  end

  def new
    @ticket = @lottery.tickets.new
  end

  def create
    @ticket = @lottery.tickets.new(ticket_params)
    return(
      redirect_to(lottery_tickets_path(@lottery))
    ) if @ticket.save

    render(:new)
  end

  def edit
    @ticket = @lottery.tickets.find(params[:id])
  end

  def update
    @ticket = @lottery.tickets.find(params[:id])
    return(
      redirect_to(lottery_tickets_path(@lottery))
    ) if @ticket.update(ticket_params)

    render(:edit)
  end

  private

  def find_lottery
    @lottery = Lottery.find(params[:lottery_id])
  end

  def ticket_params
    params.require(:ticket)
      .permit(
        :seller_id,
        :guest_id,
        :sponsor_id,
        :number,
        :state,
      )
  end
end
