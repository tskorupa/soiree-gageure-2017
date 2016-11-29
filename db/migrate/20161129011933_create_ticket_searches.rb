class CreateTicketSearches < ActiveRecord::Migration
  def change
    create_view(:ticket_searches)
  end
end
