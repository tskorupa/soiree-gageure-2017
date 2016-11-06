require 'rails_helper'

RSpec.describe(Sponsor, type: :model) do
  let(:sponsor) do
    Sponsor.create!(full_name: 'Clyde')
  end

  describe('#full_name') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:sponsors, :full_name)).to be(true)
    end
  end

  describe('#valid?') do
    it('requires :full_name to be present') do
      new_sponsor = Sponsor.new
      expect(new_sponsor).not_to be_valid
      expect(new_sponsor.errors[:full_name]).to include("can't be blank")
    end
  end

  describe('#tickets') do
    it('returns the tickets belonging to the sponsor') do
      ticket = Ticket.create!(
        number: 1,
        lottery: Lottery.create!(event_date: Date.today),
        seller: Seller.create!(full_name: 'Gonzo'),
        sponsor: sponsor,
        state: 'reserved',
      )
      expect(sponsor.tickets).to include(ticket)
    end
  end
end
