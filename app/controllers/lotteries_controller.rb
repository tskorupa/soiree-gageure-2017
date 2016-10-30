class LotteriesController < ApplicationController
  def index
    @lotteries = Lottery.all
  end

  def new
    @lottery = Lottery.new
  end

  def create
    @lottery = Lottery.new(lottery_params)
    return(redirect_to(lotteries_path)) if @lottery.save
    render(:new)
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
