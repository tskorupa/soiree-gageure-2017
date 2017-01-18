class AddDrawnToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :drawn, :boolean, null: false, default: false)
    remove_index(:tickets, [:lottery_id, :registered, :dropped_off])
    add_index(
      :tickets,
      [:lottery_id, :registered, :dropped_off, :drawn],
      name: 'by_registration_and_draw_state',
    )
  end
end
