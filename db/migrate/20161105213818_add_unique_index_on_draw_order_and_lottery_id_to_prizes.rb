class AddUniqueIndexOnDrawOrderAndLotteryIdToPrizes < ActiveRecord::Migration[5.0]
  def change
    add_index(:prizes, [:lottery_id, :draw_order], unique: true)
  end
end
