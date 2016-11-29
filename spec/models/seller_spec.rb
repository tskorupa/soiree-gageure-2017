require 'rails_helper'

RSpec.describe(Seller, type: :model) do
  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
  end

  describe('#full_name') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:sellers, :full_name)).to be(true)
    end

    it('is #stripped #sqeezed and #titleized before validation') do
      new_seller = Seller.new(full_name: ' gonzo   Chimp  ')
      new_seller.valid?
      expect(new_seller.full_name).to eq('Gonzo Chimp')
    end
  end

  describe('#valid?') do
    it('requires :full_name to be present') do
      new_seller = Seller.new
      expect(new_seller).not_to be_valid
      expect(new_seller.errors[:full_name]).to include("can't be blank")
    end
  end
end
