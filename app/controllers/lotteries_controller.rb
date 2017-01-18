class LotteriesController < ApplicationController
  def index
    @lotteries = Lottery.order(event_date: :desc)
  end

  def new
    @lottery = Lottery.new
  end

  def create
    @lottery = Lottery.new(lottery_params)
    return(redirect_to(lotteries_path)) if @lottery.save
    render(:new)
  end

  def show
    @lottery = Lottery.find(params[:id])
    @total_num_tickets = @lottery.tickets.count
    @num_unregistered_tickets = @lottery.tickets.where(registered: false).count
    @num_tickets_in_circulation = @lottery.tickets.where(registered: true, dropped_off: false).count
    @num_tickets_in_container = @lottery.tickets.where(registered: true, dropped_off: true).count
    @num_drawn_tickets = @lottery.tickets.where(registered: true, dropped_off: true, drawn: true).count
  end

  def edit
    @lottery = Lottery.find(params[:id])
  end

  def update
    @lottery = Lottery.find(params[:id])
    return(redirect_to(lotteries_path)) if @lottery.update(lottery_params)
    render(:edit)
  end

  private

  def lottery_params
    params.require(:lottery)
      .permit(:event_date, :meal_voucher_price, :ticket_price)
  end
end
