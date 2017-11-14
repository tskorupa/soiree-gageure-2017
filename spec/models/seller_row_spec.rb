# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SellerRow, type: :model) do
  include I18nSpecHelper

  describe('#row_number') do
    it('returns the attribute it was initialized with') do
      @row_number = double
      expect(seller_row.row_number).to eq(@row_number)
    end
  end

  describe('#to_param') do
    it('returns the seller id') do
      @seller = create_seller
      expect(seller_row.to_param).to eq(@seller.id.to_s)
    end
  end

  describe('#full_name') do
    it('returns the seller\'s full name') do
      @seller = create_seller
      expect(seller_row.to_param).to eq(@seller.id.to_s)
    end
  end

  describe('#edit_seller_button_name') do
    it('returns "Edit" when the locale is :en') do
      with_locale(:en) do
        expect(seller_row.edit_seller_button_name).to eq('Edit')
      end
    end

    it('returns "Modifier" when the locale is :fr') do
      with_locale(:fr) do
        expect(seller_row.edit_seller_button_name).to eq('Modifier')
      end
    end
  end

  private

  def create_seller
    Seller.create! full_name: 'Clyde'
  end

  def seller_row
    SellerRow.new(seller: @seller, row_number: @row_number)
  end
end
