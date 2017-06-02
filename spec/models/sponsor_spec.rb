# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Sponsor, type: :model) do
  let(:sponsor) do
    Sponsor.create!(full_name: 'Clyde')
  end

  describe('#full_name') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:sponsors, :full_name)).to be(true)
    end

    it('is #stripped #sqeezed and #titleized before validation') do
      new_sponsor = Sponsor.new(full_name: ' clyde   Chimp  ')
      new_sponsor.valid?
      expect(new_sponsor.full_name).to eq('Clyde Chimp')
    end
  end

  describe('#valid?') do
    it('requires :full_name to be present') do
      new_sponsor = Sponsor.new
      expect(new_sponsor).not_to be_valid
      expect(new_sponsor.errors[:full_name]).to include("can't be blank")
    end
  end
end
