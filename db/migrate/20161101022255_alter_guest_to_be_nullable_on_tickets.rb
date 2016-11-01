class AlterGuestToBeNullableOnTickets < ActiveRecord::Migration[5.0]
  def change
    change_column_null(:tickets, :guest_id, true)
  end
end
