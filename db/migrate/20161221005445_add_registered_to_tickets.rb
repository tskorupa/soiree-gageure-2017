# frozen_string_literal: true

class AddRegisteredToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :registered, :boolean, default: false, null: false)
    add_index(:tickets, %i(lottery_id registered))
  end
end
