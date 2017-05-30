# frozen_string_literal: true

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
    find_lottery
    @total_num_tickets = @lottery.tickets.count
    @num_unregistered_tickets = @lottery.tickets.where(registered: false).count
    @num_tickets_in_circulation = @lottery.tickets.where(registered: true, dropped_off: false).count
    @num_tickets_in_container = @lottery.tickets.where(dropped_off: true, drawn_position: nil).count
    @num_drawn_tickets = @lottery.tickets.where.not(drawn_position: nil).count
  end

  def edit
    find_lottery
  end

  def update
    find_lottery
    return(redirect_to(lotteries_path)) if @lottery.update(lottery_params)
    render(:edit)
  end

  private

  def find_lottery
    @lottery = Lottery.find(params[:id])
  end

  def lottery_params
    params.require(:lottery)
      .permit(:event_date, :meal_voucher_price, :ticket_price)
  end
end
