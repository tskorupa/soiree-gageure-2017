# frozen_string_literal: true
class TablesController < ApplicationController
  include LotteryLookup

  def index
    @tables = @lottery.tables.order(:number)
    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'tables/index_header',
        main_header_locals: {},
        main_partial: 'tables/index',
        main_partial_locals: {},
      },
    )
  end

  def new
    @table = @lottery.tables.new
  end

  def create
    @table = @lottery.tables.new(table_params)
    return(to_index) if @table.save

    render(:new)
  end

  def edit
    @table = @lottery.tables.find(params[:id])
  end

  def show
    @table = @lottery.tables.find(params[:id])
    @tickets = @table.tickets.includes(:seller, :guest, :sponsor).order(:number)
  end

  def update
    @table = @lottery.tables.find(params[:id])
    return(to_index) if @table.update(table_params)

    render(:edit)
  end

  private

  def to_index
    redirect_to lottery_tables_path(@table.lottery)
  end

  def table_params
    params.require(:table).permit(:number, :capacity)
  end
end
