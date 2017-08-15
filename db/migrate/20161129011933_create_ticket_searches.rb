# frozen_string_literal: true

class CreateTicketSearches < ActiveRecord::Migration[4.2]
  def change
    create_view(:ticket_searches)
  end
end
