# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SponsorListing, type: :model) do
  include I18nSpecHelper

  let(:sponsor_listing) do
    SponsorListing.new
  end

  describe('#title') do
    it('returns "Sponsors" when the locale is :en') do
      with_locale(:en) do
        expect(sponsor_listing.title).to eq('Sponsors')
      end
    end

    it('returns "Commanditaires" when the locale is :fr') do
      with_locale(:fr) do
        expect(sponsor_listing.title).to eq('Commanditaires')
      end
    end
  end

  describe('#new_sponsor_button_name') do
    it('returns "New sponsor" when the locale is :en') do
      with_locale(:en) do
        expect(sponsor_listing.new_sponsor_button_name).to eq('New sponsor')
      end
    end

    it('returns "Nouveau commanditaire" when the locale is :fr') do
      with_locale(:fr) do
        expect(sponsor_listing.new_sponsor_button_name).to eq('Nouveau commanditaire')
      end
    end
  end

  describe('#sponsor_full_name') do
    it('returns "Sponsor name" when the locale is :en') do
      with_locale(:en) do
        expect(sponsor_listing.sponsor_full_name_column_name).to eq('Sponsor name')
      end
    end

    it('returns "Nom du commanditaire" when the locale is :fr') do
      with_locale(:fr) do
        expect(sponsor_listing.sponsor_full_name_column_name).to eq('Nom du commanditaire')
      end
    end
  end

  describe('#each') do
    it('assigns a row number starting at 1 to each sponsor row') do
      2.times { |i| create_sponsor("abc#{i}") }
      row_numbers = sponsor_listing.map(&:row_number)
      expect(row_numbers).to eq([1, 2])
    end

    it('returns a SponsorRow') do
      create_sponsor
      expect(sponsor_listing.to_a).to all(be_an_instance_of(SponsorRow))
    end

    it('returns an empty result set when there are no sponsor') do
      expect(sponsor_listing.to_a).to be_empty
    end

    it('returns sponsor rows ordered by full name ASC') do
      expected = [
        create_sponsor('foo'),
        create_sponsor('bar'),
        create_sponsor('baz'),
      ].map(&:full_name).sort

      actual = sponsor_listing.map(&:sponsor_full_name)
      expect(expected).to eq(actual)
    end
  end

  private

  def create_sponsor(full_name = 'foo')
    Sponsor.create! full_name: full_name
  end
end
