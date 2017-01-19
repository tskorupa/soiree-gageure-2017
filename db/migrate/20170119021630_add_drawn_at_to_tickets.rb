class AddDrawnAtToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :drawn_at, :datetime)
    remove_index(:tickets, name: 'by_registration_and_draw_state')
    add_index(
      :tickets,
      [:lottery_id, :registered, :dropped_off, :drawn, :drawn_at],
      name: 'by_registration_and_draw',
    )
  end
end
