# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SellerRowSerializer, type: :model) do
  let(:serializer) do
    seller = Seller.create!(full_name: 'Clyde')
    seller_row = SellerRow.new(seller: seller, row_number: 1)
    SellerRowSerializer.new(seller_row)
  end

  describe('#as_json') do
    it('serializes the seller\'s full name') do
      expect(serializer.as_json).to eq(full_name: 'Clyde')
    end
  end
end
