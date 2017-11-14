# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(GuestRow, type: :model) do
  include I18nSpecHelper

  describe('#row_number') do
    it('returns the attribute it was initialized with') do
      @row_number = double
      expect(guest_row.row_number).to eq(@row_number)
    end
  end

  describe('#to_param') do
    it('returns the guest id') do
      @guest = create_guest
      expect(guest_row.to_param).to eq(@guest.id.to_s)
    end
  end

  describe('#full_name') do
    it('returns the guest\'s full name') do
      @guest = create_guest
      expect(guest_row.to_param).to eq(@guest.id.to_s)
    end
  end

  describe('#edit_guest_button_name') do
    it('returns "Edit" when the locale is :en') do
      with_locale(:en) do
        expect(guest_row.edit_guest_button_name).to eq('Edit')
      end
    end

    it('returns "Modifier" when the locale is :fr') do
      with_locale(:fr) do
        expect(guest_row.edit_guest_button_name).to eq('Modifier')
      end
    end
  end

  private

  def create_guest
    Guest.create! full_name: 'Clyde'
  end

  def guest_row
    GuestRow.new(guest: @guest, row_number: @row_number)
  end
end
