# frozen_string_literal: true

class AddUniqueIndexOnDrawOrderAndLotteryIdToPrizes < ActiveRecord::Migration[5.0]
  def change
    add_index(:prizes, %i(lottery_id draw_order), unique: true)
  end
end
