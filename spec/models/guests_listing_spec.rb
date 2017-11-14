# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(GuestsListing, type: :model) do
  include I18nSpecHelper

  let(:guests_listing) do
    GuestsListing.new
  end

  describe('#title') do
    it('returns "Guests" when the locale is :en') do
      with_locale(:en) do
        expect(guests_listing.title).to eq('Guests')
      end
    end

    it('returns "Invités" when the locale is :fr') do
      with_locale(:fr) do
        expect(guests_listing.title).to eq('Invités')
      end
    end
  end

  describe('#new_guest_button_name') do
    it('returns "New guest" when the locale is :en') do
      with_locale(:en) do
        expect(guests_listing.new_guest_button_name).to eq('New guest')
      end
    end

    it('returns "Nouvel invité" when the locale is :fr') do
      with_locale(:fr) do
        expect(guests_listing.new_guest_button_name).to eq('Nouvel invité')
      end
    end
  end

  describe('#guest_full_name') do
    it('returns "Guest name" when the locale is :en') do
      with_locale(:en) do
        expect(guests_listing.guest_full_name_column_name).to eq('Guest name')
      end
    end

    it('returns "Nom du l\'invité" when the locale is :fr') do
      with_locale(:fr) do
        expect(guests_listing.guest_full_name_column_name).to eq('Nom de l\'invité')
      end
    end
  end

  describe('#each') do
    it('assigns a row number starting at 1 to each guest row') do
      2.times { |i| create_guest("abc#{i}") }
      row_numbers = guests_listing.map(&:row_number)
      expect(row_numbers).to eq([1, 2])
    end

    it('returns a GuestRow') do
      create_guest
      expect(guests_listing.to_a).to all(be_an_instance_of(GuestRow))
    end

    it('returns an empty result set when there are no guest') do
      expect(guests_listing.to_a).to be_empty
    end

    it('returns guest rows ordered by full name ASC') do
      expected = [
        create_guest('foo'),
        create_guest('bar'),
        create_guest('baz'),
      ].map(&:full_name).sort

      actual = guests_listing.map(&:guest_full_name)
      expect(expected).to eq(actual)
    end
  end

  private

  def create_guest(full_name = 'foo')
    Guest.create! full_name: full_name
  end
end
