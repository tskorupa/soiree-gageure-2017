require 'rails_helper'

RSpec.describe(TicketSearch, type: :model) do
  let(:lottery1) do
    Lottery.create!(event_date: Date.today)
  end

  let(:lottery2) do
    Lottery.create!(event_date: Date.yesterday)
  end

  let(:ticket1) do
    Ticket.create!(
      lottery: lottery1,
      seller: Seller.create!(full_name: 'Jackson'),
      guest: Guest.create!(full_name: 'Liam'),
      sponsor: Sponsor.create!(full_name: 'Noah'),
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
    )
  end

  let(:ticket2) do
    Ticket.create!(
      lottery: lottery2,
      seller: Seller.create!(full_name: 'Jackson'),
      guest: Guest.create!(full_name: 'Liam'),
      sponsor: Sponsor.create!(full_name: 'Noah'),
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
    )
  end

  describe('#new') do
    context('when tickets number 11, 111, 112 exist') do
      before(:each) do
        @ticket_11 = Ticket.create!(
          lottery: lottery1,
          number: 11,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )
        @ticket_111 = Ticket.create!(
          lottery: lottery1,
          number: 111,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )
        @ticket_112 = Ticket.create!(
          lottery: lottery1,
          number: 112,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )
      end

      it('returns ticket#number = 11 when the query is "11"') do
        assert_equal(
          [@ticket_11],
          TicketSearch.new(lottery_id: lottery1.id, query: '11'),
        )
      end

      it('returns ticket#number = 111 when the query is "111"') do
        assert_equal(
          [@ticket_111],
          TicketSearch.new(lottery_id: lottery1.id, query: '111'),
        )
      end

      it('returns ticket#number = 112 when the query is "112"') do
        assert_equal(
          [@ticket_112],
          TicketSearch.new(lottery_id: lottery1.id, query: '112'),
        )
      end
    end

    it('returns all tickets scoped to the lottery when the query is empty') do
      assert_equal(
        [ticket1],
        TicketSearch.new(lottery_id: lottery1.id, query: ''),
      )
      assert_equal(
        [ticket2],
        TicketSearch.new(lottery_id: lottery2.id, query: ''),
      )
    end

    it('returns tickets scoped to the lottery when the query contains a ticket number') do
      assert_equal(
        [ticket1],
        TicketSearch.new(lottery_id: lottery1.id, query: 1),
      )
      assert_equal(
        [ticket2],
        TicketSearch.new(lottery_id: lottery2.id, query: 1),
      )
    end

    it('returns tickets scoped to the lottery when the query contains the seller name') do
      assert_equal(
        [ticket1],
        TicketSearch.new(lottery_id: lottery1.id, query: 'jackson'),
      )
      assert_equal(
        [ticket2],
        TicketSearch.new(lottery_id: lottery2.id, query: 'jackson'),
      )
    end

    it('returns tickets scoped to the lottery when the query contains the guest name') do
      assert_equal(
        [ticket1],
        TicketSearch.new(lottery_id: lottery1.id, query: 'liam'),
      )
      assert_equal(
        [ticket2],
        TicketSearch.new(lottery_id: lottery2.id, query: 'liam'),
      )
    end

    it('returns tickets scoped to the lottery when the query contains the sponsor name') do
      assert_equal(
        [ticket1],
        TicketSearch.new(lottery_id: lottery1.id, query: 'noah'),
      )
      assert_equal(
        [ticket2],
        TicketSearch.new(lottery_id: lottery2.id, query: 'noah'),
      )
    end

    it('returns an empty array when the query contains a ticket number for a ticket that does not exist') do
      assert_empty(TicketSearch.new(lottery_id: lottery1.id, query: 2))
      assert_empty(TicketSearch.new(lottery_id: lottery2.id, query: 2))
    end

    it('returns an empty array when the query contains a term that does not match the seller name or the guest name or the sponsor name') do
      assert_empty(TicketSearch.new(lottery_id: lottery1.id, query: 'bubbles'))
      assert_empty(TicketSearch.new(lottery_id: lottery2.id, query: 'bubbles'))
    end
  end
end
