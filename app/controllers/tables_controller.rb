class TablesController < ApplicationController
  def index
    @tables = Lottery.find(params[:lottery_id]).tables
  end

  def new
    @table = Lottery.find(params[:lottery_id]).tables.new
  end

  def create
    @table = Lottery.find(params[:lottery_id]).tables.new(table_params)
    return(
      redirect_to(lottery_tables_path(@table.lottery))
    ) if @table.save

    render(:new)
  end

  def edit
    @table = Lottery.find(params[:lottery_id]).tables.find(params[:id])
  end

  def update
    @table = Lottery.find(params[:lottery_id]).tables.find(params[:id])
    return(
      redirect_to(lottery_tables_path(@table.lottery))
    ) if @table.update(table_params)

    render(:edit)
  end

  private

  def table_params
    params.require(:table)
      .permit(:number, :capacity)
  end
end
