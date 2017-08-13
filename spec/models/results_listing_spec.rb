# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(ResultsListing, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
    )
  end

  describe('#tickets_to_display?') do
    it('returns true when the lottery contains dropped off tickets') do
      lottery.create_ticket(dropped_off: true)
      expect(results_listing.tickets_to_display?).to be(true)
    end

    it('returns false when the lottery contains no dropped off tickets') do
      lottery.create_ticket(dropped_off: false)
      expect(results_listing.tickets_to_display?).to be(false)
    end
  end

  describe('#each') do
    it('has as many rows as there are dropped off tickets in the lottery') do
      3.times { lottery.create_ticket(dropped_off: true) }
      expect(results_listing.to_a.size).to eq(3)
    end

    it('returns all drawn tickets in their draw order') do
      5.times do |i|
        lottery.create_ticket(
          dropped_off: true,
          drawn_position: 5 - i,
        )
      end

      expected_order = lottery.drawn_tickets.order(:drawn_position).map(&:id)
      actual_order = results_listing.to_a.map(&:to_param)
      expect(actual_order).to eq(expected_order)
    end

    it('assigns a row number starting at 1 to each row') do
      2.times { lottery.create_ticket(dropped_off: true) }
      row_numbers = results_listing.to_a.map(&:position)
      expect(row_numbers).to eq([1, 2])
    end

    it('returns instances of ResultRow') do
      lottery.create_ticket
      expect(results_listing.to_a).to all(be_an_instance_of(ResultsListing))
    end

    it('returns an empty result set when the lottery has no dropped off tickets') do
      expect(results_listing.to_a).to be_empty
    end

    it('returns the amount for the first announced prize in row 1') do
      Prize.create!(
        lottery: lottery,
        draw_order: 2,
        amount: 250.00,
        nth_before_last: nil,
      )
      3.times { lottery.create_ticket(dropped_off: true) }

      expected_prize_list = [250, nil, nil]
      actual_prize_list = results_listing.to_a.map(&:prize_amount)
      expect(actual_prize_list).to eq(expected_prize_list)
    end

    it('returns the amount for the grand prize in the last row') do
      Prize.create!(
        lottery: lottery,
        draw_order: 1,
        amount: 1000.00,
        nth_before_last: 0,
      )
      3.times { lottery.create_ticket(dropped_off: true) }

      expected_prize_list = [nil, nil, 1000]
      actual_prize_list = results_listing.to_a.map(&:prize_amount)
      expect(actual_prize_list).to eq(expected_prize_list)
    end

    it('returns nil as the value of the amount when no prize exists') do
      3.times { lottery.create_ticket(dropped_off: true) }

      expected_prize_list = [nil, nil, nil]
      actual_prize_list = results_listing.to_a.map(&:prize_amount)
      expect(actual_prize_list).to eq(expected_prize_list)
    end

    it('returns the amount for the n-th prize before the grand prize') do
      Prize.create!(
        lottery: lottery,
        draw_order: 123,
        amount: 200.00,
        nth_before_last: 6,
      )
      10.times { lottery.create_ticket(dropped_off: true) }

      expected_prize_list = [nil, nil, nil, 200, nil, nil, nil, nil, nil, nil]
      actual_prize_list = results_listing.to_a.map(&:prize_amount)
      expect(actual_prize_list).to eq(expected_prize_list)
    end
  end

  private

  def results_listing
    ResultsListing.new(lottery: lottery)
  end
end
