# frozen_string_literal: true

module LotteryLookup
  extend ActiveSupport::Concern

  included do
    before_action :find_lottery
  end

  private

  def find_lottery
    @lottery = Lottery.find(params[:lottery_id])
  end
end
