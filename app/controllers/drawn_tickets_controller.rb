# frozen_string_literal: true
class DrawnTicketsController < ApplicationController
  include LotteryLookup

  def index
    @results_listing = ResultsListing.new(lottery: @lottery)

    respond_to do |format|
      format.html
      format.xlsx { render_xlsx }
    end
  end

  def update
    @lottery.return_last_drawn_ticket
    redirect_to(lottery_drawn_tickets_path(@lottery))
  end

  private

  def render_xlsx
    filename = format('%s.xlsx', t('drawn_tickets.index.title'))
    render xlsx: 'results', filename: filename
  end
end
