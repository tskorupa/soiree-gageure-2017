# frozen_string_literal: true

class AddDroppedOffToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :dropped_off, :boolean, null: false, default: false)
    remove_index(:tickets, %i(lottery_id registered))
    add_index(:tickets, %i(lottery_id registered dropped_off))
  end
end
