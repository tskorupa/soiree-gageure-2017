# frozen_string_literal: true
class ResultsController < ApplicationController
  include LotteryLookup

  def index
    @ticket = @lottery.last_drawn_ticket
  end
end
