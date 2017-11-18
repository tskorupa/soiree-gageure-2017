# frozen_string_literal: true
class DrawnTicketsController < ApplicationController
  include LotteryLookup

  def index
    @results_listing = ResultsListing.new(lottery: @lottery)
  end

  def update
    @lottery.return_last_drawn_ticket
    redirect_to(lottery_drawn_tickets_path(@lottery))
  end
end
