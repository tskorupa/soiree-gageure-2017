class AddTableNumberToTicket < ActiveRecord::Migration[5.0]
  def change
    add_reference(:tickets, :table, index: true)
    add_column(:tables, :tickets_count, :integer, null: false, default: 0)
  end
end
