class PrizesController < ApplicationController
  def index
    @prizes = Lottery.find(params[:lottery_id]).prizes
  end

  def new
    @prize = Lottery.find(params[:lottery_id]).prizes.new
  end

  def create
    @prize = Lottery.find(params[:lottery_id]).prizes.new(prize_params)
    return(
      redirect_to(lottery_prizes_path(@prize.lottery))
    ) if @prize.save

    render(:new)
  end

  def edit
    @prize = Lottery.find(params[:lottery_id]).prizes.find(params[:id])
  end

  def update
    @prize = Lottery.find(params[:lottery_id]).prizes.find(params[:id])
    return(
      redirect_to(lottery_prizes_path(@prize.lottery))
    ) if @prize.update(prize_params)

    render(:edit)
  end

  private

  def prize_params
    params.require(:prize)
      .permit(:draw_order, :amount)
  end
end
