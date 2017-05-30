# frozen_string_literal: true

class AddStateToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :state, :string, null: false, default: :reserved)
    change_column_default(:tickets, :state, from: 'reserved', to: nil)
  end
end
