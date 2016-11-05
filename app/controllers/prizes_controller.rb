class PrizesController < ApplicationController
  before_action :find_lottery

  def index
    @prizes = @lottery.prizes.order(:draw_order)
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'prizes/index' },
    )
  end

  def new
    @prize = @lottery.prizes.new
  end

  def create
    @prize = @lottery.prizes.new(prize_params)
    return(
      redirect_to(lottery_prizes_path(@prize.lottery))
    ) if @prize.save

    render(:new)
  end

  def edit
    @prize = @lottery.prizes.find(params[:id])
  end

  def update
    @prize = @lottery.prizes.find(params[:id])
    return(
      redirect_to(lottery_prizes_path(@prize.lottery))
    ) if @prize.update(prize_params)

    render(:edit)
  end

  private

  def find_lottery
    @lottery = Lottery.find(params[:lottery_id])
  end

  def prize_params
    params.require(:prize).permit(:draw_order, :amount)
  end
end
