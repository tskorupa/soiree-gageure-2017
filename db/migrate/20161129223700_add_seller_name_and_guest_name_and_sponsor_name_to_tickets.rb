# frozen_string_literal: true

class AddSellerNameAndGuestNameAndSponsorNameToTickets < ActiveRecord::Migration[5.0]
  def change
    add_column(:tickets, :seller_name, :string)
    add_column(:tickets, :guest_name, :string)
    add_column(:tickets, :sponsor_name, :string)

    change_column_null(:tickets, :seller_id, true)
  end
end
