class DropSellerNameAndGuestNameAndSponsorNameFromTickets < ActiveRecord::Migration[5.0]
  def change
    remove_columns(:tickets, :seller_name, :guest_name, :sponsor_name)
  end
end
