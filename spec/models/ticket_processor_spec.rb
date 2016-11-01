require 'rails_helper'

RSpec.describe(TicketProcessor, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
  end

  let(:ticket_processor) do
    TicketProcessor.new(lottery)
  end

  describe('#reserve') do
    it('creates tickets for all numbers that do not exist') do
      expect do
        ticket_processor.reserve(numbers: 1..10, seller: seller)
      end.to change { Ticket.where(seller_id: seller.id).count }.by(10)
    end

    it('assigns tickets for all numbers to the seller') do
      expect do
        ticket_processor.reserve(numbers: [1], seller: seller)
      end.to change { Ticket.where(number: 1, seller_id: seller.id).exists? }.from(false).to(true)
    end

    it('does not re-assign a ticket number to the same seller') do
      ticket = Ticket.create!(
        lottery: lottery,
        seller: seller,
        number: 1,
      )
      expect do
        ticket_processor.reserve(numbers: [1], seller: seller)
      end.not_to change { ticket.reload.updated_at }
    end

    it('re-assigns a ticket number to a new seller') do
      ticket = Ticket.create!(
        lottery: lottery,
        seller: seller,
        number: 1,
      )
      new_seller = Seller.create!(full_name: 'George')
      expect do
        ticket_processor.reserve(numbers: [1], seller: new_seller)
      end.to change { ticket.reload.seller }.from(seller).to(new_seller)
    end

    it('rollsback all changes when encountering an exception') do
      RSpec::Matchers.define_negated_matcher(:not_change, :change)
      RSpec::Expectations.configuration.on_potential_false_positives = :nothing
      expect do
        ticket_processor.reserve(numbers: [1, 2, nil, 4], seller: seller)
      end.to raise_error.and not_change { Ticket.count }
    end
  end
end
