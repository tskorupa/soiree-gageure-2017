require 'rails_helper'

RSpec.describe(TicketSearch, type: :model) do
  before(:each) do
    @lottery1 = Lottery.create!(event_date: Date.today)
    @ticket1 = Ticket.create!(
      lottery: @lottery1,
      seller_name: 'Jackson',
      guest_name: 'Liam',
      sponsor_name: 'Noah',
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
    )
    @lottery2 = Lottery.create!(event_date: Date.yesterday)
    @ticket2 = Ticket.create!(
      lottery: @lottery2,
      seller_name: 'Jackson',
      guest_name: 'Liam',
      sponsor_name: 'Noah',
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
    )
  end

  describe('#new') do
    it('returns all tickets scoped to the lottery when the query is empty') do
      assert_equal(
        [@ticket1],
        TicketSearch.new(lottery_id: @lottery1.id, query: ''),
      )
      assert_equal(
        [@ticket2],
        TicketSearch.new(lottery_id: @lottery2.id, query: ''),
      )
    end

    it('returns tickets scoped to the lottery when the query contains a ticket number') do
      assert_equal(
        [@ticket1],
        TicketSearch.new(lottery_id: @lottery1.id, query: 1),
      )
      assert_equal(
        [@ticket2],
        TicketSearch.new(lottery_id: @lottery2.id, query: 1),
      )
    end

    it('returns tickets scoped to the lottery when the query contains the seller name') do
      assert_equal(
        [@ticket1],
        TicketSearch.new(lottery_id: @lottery1.id, query: 'jackson'),
      )
      assert_equal(
        [@ticket2],
        TicketSearch.new(lottery_id: @lottery2.id, query: 'jackson'),
      )
    end

    it('returns tickets scoped to the lottery when the query contains the guest name') do
      assert_equal(
        [@ticket1],
        TicketSearch.new(lottery_id: @lottery1.id, query: 'liam'),
      )
      assert_equal(
        [@ticket2],
        TicketSearch.new(lottery_id: @lottery2.id, query: 'liam'),
      )
    end

    it('returns tickets scoped to the lottery when the query contains the sponsor name') do
      assert_equal(
        [@ticket1],
        TicketSearch.new(lottery_id: @lottery1.id, query: 'noah'),
      )
      assert_equal(
        [@ticket2],
        TicketSearch.new(lottery_id: @lottery2.id, query: 'noah'),
      )
    end

    it('returns an empty array when the query contains a ticket number for a ticket that does not exist') do
      assert_empty(TicketSearch.new(lottery_id: @lottery1.id, query: 2))
      assert_empty(TicketSearch.new(lottery_id: @lottery2.id, query: 2))
    end

    it('returns an empty array when the query contains a term that does not match the seller name or the guest name or the sponsor name') do
      assert_empty(TicketSearch.new(lottery_id: @lottery1.id, query: 'bubbles'))
      assert_empty(TicketSearch.new(lottery_id: @lottery2.id, query: 'bubbles'))
    end
  end
end
