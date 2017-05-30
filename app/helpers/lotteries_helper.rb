# frozen_string_literal: true

module LotteriesHelper
  def lock_or_unlock(lottery)
    action = if lottery.locked?
      'unlock'
    else
      'lock'
    end

    t(format('helpers.submit.lock_lotteries.update.%s', action))
  end
end
