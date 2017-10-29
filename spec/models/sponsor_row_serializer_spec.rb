# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SponsorRowSerializer, type: :model) do
  let(:serializer) do
    sponsor = Sponsor.create!(full_name: 'Clyde')
    sponsor_row = SponsorRow.new(sponsor: sponsor, row_number: 1)
    SponsorRowSerializer.new(sponsor_row)
  end

  describe('#as_json') do
    it('serializes the sponsor\'s full name') do
      expect(serializer.as_json).to eq(full_name: 'Clyde')
    end
  end
end
