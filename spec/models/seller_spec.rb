require 'rails_helper'

RSpec.describe(Seller, type: :model) do
  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
  end

  describe('#full_name') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:sellers, :full_name)).to be(true)
    end
  end

  describe('#valid?') do
    it('requires :full_name to be present') do
      new_seller = Seller.new
      expect(new_seller).not_to be_valid
      expect(new_seller.errors[:full_name]).to include("can't be blank")
    end
  end

  describe('#tickets') do
    before(:each) do
      Ticket.create!(
        number: 1,
        lottery: Lottery.create!(event_date: Date.today),
        seller: seller,
        state: 'reserved',
      )
    end

    it('returns the tickets belonging to the seller') do
      expect(seller.tickets).to eq(Ticket.where(seller_id: seller.id))
    end
  end
end
