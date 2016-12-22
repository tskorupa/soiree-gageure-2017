class AddRegisteredToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :registered, :boolean, default: false, null: false)
    add_index(:tickets, [:lottery_id, :registered])
  end
end
