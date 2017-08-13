# frozen_string_literal: true
class DrawnTicketsController < ApplicationController
  include LotteryLookup

  def index
    @results_listing = ResultsListing.new(lottery: @lottery)

    main_partial = if @results_listing.tickets_to_display?
      'drawn_tickets/index'
    else
      'drawn_tickets/no_tickets_index'
    end

    render(
      'lotteries/lottery_child_index',
      locals: {
        main_header: 'drawn_tickets/listing_header',
        main_header_locals: {},
        main_partial: main_partial,
        main_partial_locals: {},
      },
    )
  end

  def update
    @lottery.return_last_drawn_ticket
    redirect_to(lottery_drawn_tickets_path(@lottery))
  end
end
