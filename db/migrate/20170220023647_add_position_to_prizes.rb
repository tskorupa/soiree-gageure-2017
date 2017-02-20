class AddPositionToPrizes < ActiveRecord::Migration[5.0]
  def change
    add_column(:prizes, :nth_before_last, :integer)
    add_index(:prizes, [:lottery_id, :nth_before_last], unique: true)
  end
end
