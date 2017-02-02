class AddLockedToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column(:lotteries, :locked, :boolean, null: false, default: false)
    add_index(:lotteries, :locked)
  end
end
