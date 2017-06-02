# frozen_string_literal: true

class LockLotteriesController < ApplicationController
  def update
    lottery = Lottery.find(params[:id])
    lottery.update!(locked: !lottery.locked)
    redirect_to(lotteries_path)
  end
end
