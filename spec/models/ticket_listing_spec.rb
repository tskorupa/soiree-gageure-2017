# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketListing, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:ticket_listing) do
    TicketListing.new(lottery: lottery)
  end

  describe('#number_filter') do
    it('returns nil when the attribute was not initialized') do
      expect(ticket_listing.number_filter).to be_nil
    end

    it('returns the initialized number filter') do
      number_filter_double = double
      ticket_listing = TicketListing.new(
        lottery: lottery,
        number_filter: number_filter_double,
      )
      expect(ticket_listing.number_filter).to be(number_filter_double)
    end
  end

  describe('#tickets_to_display?') do
    it('returns true when there are tickets to display') do
      lottery.create_ticket
      expect(ticket_listing.tickets_to_display?).to be(true)
    end

    it('returns false when there are no tickets to display') do
      expect(ticket_listing.tickets_to_display?).to be(false)
    end
  end

  describe('#each') do
    it('returns an empty result set when the lootery has no tickets') do
      skip
    end

    it('returns an instance of TicketPresenter for each lottery ticket') do
      skip
    end

    it('returns a ticket presenter when the lottery contains a ticket corresponding to the number filter') do
      skip
    end

    it('returns an empty result set when the lottery contains no tickets corresponding to the number filter') do
      skip
    end
  end
end
