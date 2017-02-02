class TicketImpressionsController < ApplicationController
  include LotteryLookup

  def index
    @number = params[:number]
    @tickets = printable_tickets.order(:number)
    @tickets = @tickets.where(number: @number) if @number.present?

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'ticket_impressions/index' },
    )
  end

  def show
    @ticket = printable_tickets.find(params[:id])

    respond_to do |format|
      format.pdf do
        file_name = format(
          '%s_%i',
          Ticket.model_name.human.downcase,
          @ticket.number,
        )

        render(
          pdf: file_name,
          page_width: 62,
          page_height: 29,
          encoding: 'UTF-8',
        )
      end
    end
  end

  private

  def printable_tickets
    @lottery.tickets.where(
      ticket_type: 'meal_and_lottery',
      registered: true,
    )
  end
end
