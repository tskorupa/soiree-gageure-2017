class ConvertStateSoldToPaidOnTickets < ActiveRecord::Migration[5.0]
  def up
    Ticket.where(state: 'sold').update_all(state: 'paid')
  end

  def down
    Ticket.where(state: 'paid').update_all(state: 'sold')
  end
end
