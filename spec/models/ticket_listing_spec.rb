# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketListing, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:ticket_listing) do
    TicketListing.new(ticket_scope: lottery.tickets)
  end

  describe('#number_filter') do
    it('returns nil when the attribute was not initialized') do
      expect(ticket_listing.number_filter).to be_nil
    end

    it('returns the initialized number filter') do
      number_filter_double = double
      ticket_listing = TicketListing.new(
        ticket_scope: lottery.tickets,
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

    it('returns true when the lottery contains a ticket corresponding to the number filter') do
      lottery.create_ticket(number: 13)
      ticket_listing = TicketListing.new(ticket_scope: lottery.tickets, number_filter: 13)
      expect(ticket_listing.tickets_to_display?).to be(true)
    end

    it('returns false when the lottery contains no tickets corresponding to the number filter') do
      ticket_listing = TicketListing.new(ticket_scope: lottery.tickets, number_filter: 13)
      expect(ticket_listing.tickets_to_display?).to be(false)
    end
  end

  describe('#each') do
    it('assigns a row number starting at 1 to each ticket row') do
      2.times { lottery.create_ticket }
      row_numbers = ticket_listing.map(&:row_number)
      expect(row_numbers).to eq([1, 2])
    end

    it('wraps each lottery ticket in a TicketPresenter') do
      lottery.create_ticket
      expect(ticket_listing.to_a).to all(be_an_instance_of(TicketPresenter))
    end

    it('returns an empty result set when the lottery has no tickets') do
      expect(ticket_listing.to_a).to be_empty
    end

    it('returns a ticket presenter when the lottery contains a ticket corresponding to the number filter') do
      lottery.create_ticket(number: 13)
      ticket_listing = TicketListing.new(ticket_scope: lottery.tickets, number_filter: 13)
      expect(ticket_listing.to_a).to be_present
    end

    it('returns an empty result set when the lottery contains no tickets corresponding to the number filter') do
      ticket_listing = TicketListing.new(ticket_scope: lottery.tickets, number_filter: 13)
      expect(ticket_listing.to_a).to be_empty
    end
  end
end
