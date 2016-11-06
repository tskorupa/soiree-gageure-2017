class TicketProcessor
  def initialize(lottery)
    @lottery = lottery
  end

  def reserve(numbers:, seller:)
    Ticket.transaction do
      numbers.each do |number|
        ticket = Ticket.find_or_initialize_by(
          lottery: lottery,
          number: number,
          state: 'reserved',
        )
        next if ticket.seller_id == seller.id

        ticket.seller = seller
        ticket.save!
      end
    end
  end

  private

  attr_reader :lottery
end
