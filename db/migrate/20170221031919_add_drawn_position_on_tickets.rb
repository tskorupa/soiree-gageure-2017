# frozen_string_literal: true

class AddDrawnPositionOnTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :drawn_position, :integer)
    add_index(:tickets, %i(lottery_id drawn_position), unique: true, order: :drawn_position)
    remove_column(:tickets, :drawn_at, :datetime)
    remove_column(:tickets, :drawn, :boolean, null: false, default: false)
  end
end
