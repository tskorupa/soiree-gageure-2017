# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SponsorRow, type: :model) do
  include I18nSpecHelper

  describe('#row_number') do
    it('returns the attribute it was initialized with') do
      @row_number = double
      expect(sponsor_row.row_number).to eq(@row_number)
    end
  end

  describe('#to_param') do
    it('returns the sponsor id') do
      @sponsor = create_sponsor
      expect(sponsor_row.to_param).to eq(@sponsor.id.to_s)
    end
  end

  describe('#full_name') do
    it('returns the sponsor\'s full name') do
      @sponsor = create_sponsor
      expect(sponsor_row.to_param).to eq(@sponsor.id.to_s)
    end
  end

  describe('#edit_sponsor_button_name') do
    it('returns "Edit" when the locale is :en') do
      with_locale(:en) do
        expect(sponsor_row.edit_sponsor_button_name).to eq('Edit')
      end
    end

    it('returns "Modifier" when the locale is :fr') do
      with_locale(:fr) do
        expect(sponsor_row.edit_sponsor_button_name).to eq('Modifier')
      end
    end
  end

  private

  def create_sponsor
    Sponsor.create! full_name: 'Clyde'
  end

  def sponsor_row
    SponsorRow.new(sponsor: @sponsor, row_number: @row_number)
  end
end
