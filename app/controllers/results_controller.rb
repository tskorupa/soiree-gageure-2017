# frozen_string_literal: true
class ResultsController < ApplicationController
  include LotteryLookup

  def index
    @results_index = ResultsIndex.new(lottery: @lottery)
  end
end
