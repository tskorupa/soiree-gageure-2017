require 'rails_helper'

RSpec.describe(DrawResultsListing, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
    )
  end

  describe('.draw_results') do
    let(:draw_results) do
      DrawResultsListing.draw_results(
        prizes: @prizes,
        drawn_tickets: @drawn_tickets,
        dropped_off_tickets_count: @dropped_off_tickets_count,
      )
    end

    it('returns nil when dropped_off_tickets_count: 0') do
      @dropped_off_tickets_count = 0
      expect(draw_results).to be_nil
    end

    it('returns [1, 2, 3, 4, 5] when drawn_tickets: [] and dropped_off_tickets_count: 5') do
      @drawn_tickets = Ticket.none
      @dropped_off_tickets_count = 5
      @prizes = Prize.none
      expect(draw_results).to eq([[1, nil], [2, nil], [3, nil], [4, nil], [5, nil]])
    end

    it('returns [[1, <ticket>], [2, nil], [3, nil]] when drawn_tickets: [<ticket>] and dropped_off_tickets_count: 3 and prizes: []') do
      @drawn_tickets = Ticket.where(id: ticket.id)
      @dropped_off_tickets_count = 3
      @prizes = Prize.none
      expect(draw_results).to eq([[1, ticket], [2, nil], [3, nil]])
    end

    it('returns [[1, <ticket>, $3.51], [2, nil], [3, nil]] when drawn_tickets: [<ticket>] and dropped_off_tickets_count: 3 and prizes: [<prize nth_before_last: nil>]') do
      @drawn_tickets = Ticket.where(id: ticket.id)
      @dropped_off_tickets_count = 3
      lottery.prizes.create!(draw_order: 22, amount: 3.51, nth_before_last: nil)
      @prizes = lottery.prizes
      expect(draw_results).to eq([[1, ticket, 3.51], [2, nil], [3, nil]])
    end

    it('returns [[1, <ticket>], [2, nil], [3, nil, $3.51]] when drawn_tickets: [<ticket>] and dropped_off_tickets_count: 3 and prizes: [<prize nth_before_last: 0>]') do
      @drawn_tickets = Ticket.where(id: ticket.id)
      @dropped_off_tickets_count = 3
      lottery.prizes.create!(draw_order: 22, amount: 3.51, nth_before_last: 0)
      @prizes = lottery.prizes
      expect(draw_results).to eq([[1, ticket], [2, nil], [3, nil, 3.51]])
    end

    it('returns [[1, <ticket>], [2, nil], [3, nil, $3.51], [4, nil], [5, nil]] when drawn_tickets: [<ticket>] and dropped_off_tickets_count: 5 and prizes: [<prize nth_before_last: 2>]') do
      @drawn_tickets = Ticket.where(id: ticket.id)
      @dropped_off_tickets_count = 5
      lottery.prizes.create!(draw_order: 22, amount: 3.51, nth_before_last: 2)
      @prizes = lottery.prizes
      expect(draw_results).to eq([[1, ticket], [2, nil], [3, nil, 3.51], [4, nil], [5, nil]])
    end
  end
end
