class TablesController < ApplicationController
  before_action :find_lottery

  def index
    @tables = @lottery.tables.order(:number)
    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'tables/index' },
    )
  end

  def new
    @table = @lottery.tables.new
  end

  def create
    @table = @lottery.tables.new(table_params)
    return(
      redirect_to(lottery_tables_path(@table.lottery))
    ) if @table.save

    render(:new)
  end

  def edit
    @table = @lottery.tables.find(params[:id])
  end

  def update
    @table = @lottery.tables.find(params[:id])
    return(
      redirect_to(lottery_tables_path(@table.lottery))
    ) if @table.update(table_params)

    render(:edit)
  end

  private

  def find_lottery
    @lottery = Lottery.find(params[:lottery_id])
  end

  def table_params
    params.require(:table).permit(:number, :capacity)
  end
end
