# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(GuestRowSerializer, type: :model) do
  let(:serializer) do
    guest = Guest.create!(full_name: 'Clyde')
    guest_row = GuestRow.new(guest: guest, row_number: 1)
    GuestRowSerializer.new(guest_row)
  end

  describe('#as_json') do
    it('serializes the guest\'s full name') do
      expect(serializer.as_json).to eq(full_name: 'Clyde')
    end
  end
end
