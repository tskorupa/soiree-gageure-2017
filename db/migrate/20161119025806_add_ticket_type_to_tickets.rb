# frozen_string_literal: true

class AddTicketTypeToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :ticket_type, :string)
    Ticket.update_all(ticket_type: 'meal_and_lottery')
    change_column_null(:tickets, :ticket_type, false)
  end
end
