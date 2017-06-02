# frozen_string_literal: true

class PrizesController < ApplicationController
  include LotteryLookup

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
    return(to_index) if @prize.save

    render(:new)
  end

  def edit
    @prize = @lottery.prizes.find(params[:id])
  end

  def update
    @prize = @lottery.prizes.find(params[:id])
    return(to_index) if @prize.update(prize_params)

    render(:edit)
  end

  private

  def to_index
    redirect_to lottery_prizes_path(@prize.lottery)
  end

  def prize_params
    params.require(:prize).permit(
      :draw_order,
      :nth_before_last,
      :amount,
    )
  end
end
