# frozen_string_literal: true

class DropTicketSearches < ActiveRecord::Migration[5.0]
  def up
    drop_view(:ticket_searches)
  end

  def down
    create_view(:ticket_searches, version: 3)
  end
end
