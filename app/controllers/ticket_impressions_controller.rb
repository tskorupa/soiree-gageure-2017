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
    respond_to(:pdf)

    ticket = printable_tickets.includes(:guest, :table).find(params[:id])
    pdf = TicketPdf.new(ticket: ticket)
    send_data(
      pdf.render,
      filename: pdf.filename,
      type: 'application/pdf',
      disposition: 'inline',
    )
  end

  private

  def printable_tickets
    @lottery.tickets.where(
      ticket_type: 'meal_and_lottery',
      registered: true,
    )
  end
end
