# frozen_string_literal: true
class TicketsDashboardsController < ApplicationController
  include LotteryLookup

  def show
    @tickets_dashboard = TicketsDashboard.new(lottery: @lottery)
  end
end
