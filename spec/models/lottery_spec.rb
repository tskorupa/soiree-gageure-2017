require 'rails_helper'

RSpec.describe(Lottery, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  describe('#create_ticket') do
    it('returns a persisted ticket') do
      expect(lottery.create_ticket).to be_persisted
    end

    it('returns a ticket belonging to the lottery') do
      ticket = lottery.create_ticket
      expect(ticket.lottery).to eq(lottery)
    end

    it('returns a ticket where #number defaults to the largest existing ticket number + 1') do
      lottery.create_ticket(number: 300)
      ticket = lottery.create_ticket
      expect(ticket.number).to eq(301)
    end

    it('returns a ticket where #state == "reserved"') do
      ticket = lottery.create_ticket
      expect(ticket.state).to eq('reserved')
    end

    it('returns a ticket where #ticket_type == "meal_and_lottery"') do
      ticket = lottery.create_ticket
      expect(ticket.ticket_type).to eq('meal_and_lottery')
    end

    it('returns a ticket with configurable attributes') do
      ticket = lottery.create_ticket(
        number: 300,
        state: 'paid',
        ticket_type: 'lottery_only',
        dropped_off: true,
      )
      expect(ticket.number).to eq(300)
      expect(ticket.state).to eq('paid')
      expect(ticket.ticket_type).to eq('lottery_only')
      expect(ticket.dropped_off).to be(true)
    end
  end

  describe('#drawable_tickets') do
    it('returns all tickets belonging to the lottery where ticket#dropped_off == true and ticket#drawn_position is nil') do
      ticket = lottery.create_ticket(
        dropped_off: true,
        drawn_position: nil,
      )
      expect(lottery.drawable_tickets).to eq([ticket])
    end

    it('does not return tickets belonging to a different lottery where ticket#dropped_off == true and ticket#drawn_position is nil') do
      Lottery.create(event_date: Date.today).create_ticket(
        dropped_off: false,
        drawn_position: nil,
      )
      expect(lottery.drawable_tickets).to be_empty
    end

    it('does not return tickets belonging to the lottery where ticket#dropped_off != true and ticket#drawn_position is nil') do
      lottery.create_ticket(
        dropped_off: false,
        drawn_position: nil,
      )
      expect(lottery.drawable_tickets).to be_empty
    end

    it('does not return tickets belonging to the lottery where ticket#dropped_off == true and ticket#drawn_position is not nil') do
      lottery.create_ticket(
        dropped_off: true,
        drawn_position: 1,
      )
      expect(lottery.drawable_tickets).to be_empty
    end
  end

  describe('#drawn_tickets') do
    it('returns all tickets belonging to the lottery where ticket#drawn_position != nil') do
      ticket = lottery.create_ticket(drawn_position: 1)
      expect(lottery.drawn_tickets).to eq([ticket])
    end

    it('does not return tickets belonging to the lottery where ticket#drawn_position == nil') do
      lottery.create_ticket(drawn_position: nil)
      expect(lottery.drawn_tickets).to be_empty
    end

    it('does not return tickets belonging to another lottery where ticket#drawn_position != nil') do
      Lottery.create!(event_date: Date.today).create_ticket(drawn_position: 1)
      expect(lottery.drawn_tickets).to be_empty
    end
  end

  describe('#last_drawn_ticket') do
    it('returns the ticket belonging to the lottery with the largest ticket#drawn_position') do
      ticket = lottery.create_ticket(drawn_position: 3)
      lottery.create_ticket(drawn_position: 2)
      expect(lottery.last_drawn_ticket).to eq(ticket)
    end

    it('returns nil when all tickets belonging to the lottery have ticket#drawn_position == nil') do
      lottery.create_ticket(drawn_position: nil)
      expect(lottery.last_drawn_ticket).to be_nil
    end

    it('returns nil when the lottery has no tickets') do
      Lottery.create(event_date: Date.today).create_ticket(drawn_position: 1)
      expect(lottery.last_drawn_ticket).to be_nil
    end
  end

  describe('#event_date') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:lotteries, :event_date)).to be(true)
    end
  end

  describe('#valid?') do
    it('requires :event_date to be present') do
      new_lottery = Lottery.new
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:event_date]).to include("can't be blank")
    end

    it('requires :ticket_price to be greater than 0 when attribute present') do
      new_lottery = Lottery.new(ticket_price: 0)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:ticket_price]).to include("must be greater than 0")
    end

    it('requires :ticket_price to be less than 10_000 when attribute present') do
      new_lottery = Lottery.new(ticket_price: 10_000)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:ticket_price]).to include("must be less than 10000")
    end

    it('does not validate :ticket_price when attribute is nil') do
      new_lottery = Lottery.new(ticket_price: nil)
      new_lottery.valid?
      expect(new_lottery.errors).not_to include(:ticket_price)
    end

    it('requires :meal_voucher_price to be greater than 0 when attribute present') do
      new_lottery = Lottery.new(meal_voucher_price: 0)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:meal_voucher_price]).to include("must be greater than 0")
    end

    it('requires :meal_voucher_price to be less than 10_000 when attribute present') do
      new_lottery = Lottery.new(meal_voucher_price: 10_000)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:meal_voucher_price]).to include("must be less than 10000")
    end

    it('does not validate :meal_voucher_price when attribute is nil') do
      new_lottery = Lottery.new(meal_voucher_price: nil)
      new_lottery.valid?
      expect(new_lottery.errors).not_to include(:meal_voucher_price)
    end
  end

  describe('#prizes') do
    before(:each) do
      Prize.create!(
        lottery: lottery,
        draw_order: 1,
        amount: 250.00,
      )
    end

    it('returns the prizes belonging to the lottery') do
      expect(lottery.prizes).to eq(Prize.where(lottery_id: lottery.id))
    end
  end

  describe('#tables') do
    before(:each) do
      Table.create!(
        lottery: lottery,
        number: 1,
        capacity: 6,
      )
    end

    it('returns the prizes belonging to the lottery') do
      expect(lottery.prizes).to eq(Prize.where(lottery_id: lottery.id))
    end
  end

  describe('#tickets') do
    it('returns the tickets belonging to the lottery') do
      Ticket.create!(
        number: 1,
        lottery: lottery,
        state: 'reserved',
        ticket_type: 'meal_and_lottery',
      )
      expect(lottery.tickets).to eq(Ticket.where(lottery_id: lottery.id))
    end
  end
end
