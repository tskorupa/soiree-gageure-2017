# frozen_string_literal: true
class TicketImpressionsController < ApplicationController
  include LotteryLookup

  def index
    @ticket_listing = TicketListing.new(
      ticket_scope: @lottery.printable_tickets,
      number_filter: params[:number_filter],
    )
  end

  def show
    respond_to(:pdf)

    ticket = @lottery.printable_tickets.includes(:guest, :table).find(params[:id])
    pdf = TicketPdf.new(ticket: ticket)
    send_data(
      pdf.render,
      filename: pdf.filename,
      type: 'application/pdf',
      disposition: 'inline',
    )
  end
end
