class AddReferenceToTicketOnPrize < ActiveRecord::Migration[5.0]
  def change
    add_reference(:prizes, :ticket, index: { unique: true })
  end
end
