class TicketsController < ApplicationController
  def index
    @tickets = Lottery.find(params[:lottery_id]).tickets
  end

  def new
    @ticket = Lottery.find(params[:lottery_id]).tickets.new
  end

  def create
    @ticket = Lottery.find(params[:lottery_id]).tickets.new(ticket_params)
    return(
      redirect_to(lottery_tickets_path(@ticket.lottery))
    ) if @ticket.save

    render(:new)
  end

  def edit
    @ticket = Lottery.find(params[:lottery_id]).tickets.find(params[:id])
  end

  def update
    @ticket = Lottery.find(params[:lottery_id]).tickets.find(params[:id])
    return(
      redirect_to(lottery_tickets_path(@ticket.lottery))
    ) if @ticket.update(ticket_params)

    render(:edit)
  end

  private

  def ticket_params
    params.require(:ticket).permit(:seller_id, :guest_id, :number)
  end
end
