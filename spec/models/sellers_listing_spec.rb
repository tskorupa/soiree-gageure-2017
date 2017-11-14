# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SellersListing, type: :model) do
  include I18nSpecHelper

  let(:sellers_listing) do
    SellersListing.new
  end

  describe('#title') do
    it('returns "Sellers" when the locale is :en') do
      with_locale(:en) do
        expect(sellers_listing.title).to eq('Sellers')
      end
    end

    it('returns "Vendeurs" when the locale is :fr') do
      with_locale(:fr) do
        expect(sellers_listing.title).to eq('Vendeurs')
      end
    end
  end

  describe('#new_seller_button_name') do
    it('returns "New seller" when the locale is :en') do
      with_locale(:en) do
        expect(sellers_listing.new_seller_button_name).to eq('New seller')
      end
    end

    it('returns "Nouveau vendeur" when the locale is :fr') do
      with_locale(:fr) do
        expect(sellers_listing.new_seller_button_name).to eq('Nouveau vendeur')
      end
    end
  end

  describe('#seller_full_name') do
    it('returns "Seller name" when the locale is :en') do
      with_locale(:en) do
        expect(sellers_listing.seller_full_name_column_name).to eq('Seller name')
      end
    end

    it('returns "Nom du vendeur" when the locale is :fr') do
      with_locale(:fr) do
        expect(sellers_listing.seller_full_name_column_name).to eq('Nom du vendeur')
      end
    end
  end

  describe('#each') do
    it('assigns a row number starting at 1 to each seller row') do
      2.times { |i| create_seller("abc#{i}") }
      row_numbers = sellers_listing.map(&:row_number)
      expect(row_numbers).to eq([1, 2])
    end

    it('returns a SellerRow') do
      create_seller
      expect(sellers_listing.to_a).to all(be_an_instance_of(SellerRow))
    end

    it('returns an empty result set when there are no seller') do
      expect(sellers_listing.to_a).to be_empty
    end

    it('returns seller rows ordered by full name ASC') do
      expected = [
        create_seller('foo'),
        create_seller('bar'),
        create_seller('baz'),
      ].map(&:full_name).sort

      actual = sellers_listing.map(&:seller_full_name)
      expect(expected).to eq(actual)
    end
  end

  private

  def create_seller(full_name = 'foo')
    Seller.create! full_name: full_name
  end
end
