# frozen_string_literal: true
class ResultsController < ApplicationController
  include LotteryLookup

  def index
    last_drawn_ticket = @lottery.last_drawn_ticket
    @ticket = LastDrawnTicket.new(ticket: last_drawn_ticket) if last_drawn_ticket
  end
end
