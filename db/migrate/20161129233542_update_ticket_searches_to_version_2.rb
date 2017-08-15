# frozen_string_literal: true

class UpdateTicketSearchesToVersion2 < ActiveRecord::Migration[4.2]
  def change
    update_view(:ticket_searches, version: 2, revert_to_version: 1)
  end
end
