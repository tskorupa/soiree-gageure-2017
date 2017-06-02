# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Guest, type: :model) do
  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  describe('#full_name') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:guests, :full_name)).to be(true)
    end

    it('is #stripped #sqeezed and #titleized before validation') do
      new_guest = Guest.new(full_name: ' bubbles   Chimp  ')
      new_guest.valid?
      expect(new_guest.full_name).to eq('Bubbles Chimp')
    end
  end

  describe('#valid?') do
    it('requires :full_name to be present') do
      new_guest = Guest.new
      expect(new_guest).not_to be_valid
      expect(new_guest.errors[:full_name]).to include("can't be blank")
    end
  end
end
