# frozen_string_literal: true

class CreateTicketSearches < ActiveRecord::Migration
  def change
    create_view(:ticket_searches)
  end
end
