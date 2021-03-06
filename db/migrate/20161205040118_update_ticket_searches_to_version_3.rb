# frozen_string_literal: true

class UpdateTicketSearchesToVersion3 < ActiveRecord::Migration[4.2]
  def change
    replace_view(:ticket_searches, version: 3, revert_to_version: 2)
  end
end
