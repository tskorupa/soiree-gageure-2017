# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Lottery, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  describe('#reserved_tickets') do
    it('returns tickets with state == "reserved"') do
      ticket = lottery.create_ticket(state: 'reserved')
      expect(lottery.reserved_tickets).to eq([ticket])
    end

    it('does not return tickets with state == "authorized"') do
      lottery.create_ticket(state: 'authorized')
      expect(lottery.reserved_tickets).to be_empty
    end

    it('does not return tickets with state == "paid"') do
      lottery.create_ticket(state: 'paid')
      expect(lottery.reserved_tickets).to be_empty
    end
  end

  describe('#registerable_tickets') do
    it('does not return tickets when ticket#registered == true') do
      lottery.create_ticket(registered: true)
      expect(lottery.registerable_tickets).to be_empty
    end

    it('does not return tickets when ticket#state == "reserved"') do
      lottery.create_ticket(state: 'reserved')
      expect(lottery.registerable_tickets).to be_empty
    end

    it('returns tickets when ticket#registered == false and ticket#state == "authorized"') do
      ticket = lottery.create_ticket(
        registered: false,
        state: 'authorized',
      )
      expect(lottery.registerable_tickets).to eq([ticket])
    end

    it('does not return tickets belonging to a different lottery when ticket#registered == false and ticket#state == "authorized"') do
      Lottery.create(event_date: Time.zone.tomorrow).create_ticket(
        registered: false,
        state: 'authorized',
      )
      expect(lottery.registerable_tickets).to be_empty
    end

    it('returns tickets when ticket#registered == false and ticket#state == "paid"') do
      ticket = lottery.create_ticket(
        registered: false,
        state: 'paid',
      )
      expect(lottery.registerable_tickets).to eq([ticket])
    end

    it('does not return tickets belonging to a different lottery when ticket#registered == false and ticket#state == "paid"') do
      Lottery.create(event_date: Time.zone.tomorrow).create_ticket(
        registered: false,
        state: 'paid',
      )
      expect(lottery.registerable_tickets).to be_empty
    end
  end

  describe('#droppable_tickets') do
    it('returns tickets with ticket#registered == true and ticket#dropped_off == false') do
      ticket = lottery.create_ticket(registered: true, dropped_off: false)
      expect(lottery.droppable_tickets).to eq([ticket])
    end

    it('does not return tickets with ticket#registered == false and ticket#dropped_off == false') do
      lottery.create_ticket(registered: false, dropped_off: false)
      expect(lottery.droppable_tickets).to be_empty
    end

    it('does not return tickets with ticket#registered == true and ticket#dropped_off == true') do
      lottery.create_ticket(registered: true, dropped_off: true)
      expect(lottery.droppable_tickets).to be_empty
    end

    it('does not return tickets with ticket#registered == false and ticket#dropped_off == true') do
      lottery.create_ticket(registered: false, dropped_off: true)
      expect(lottery.droppable_tickets).to be_empty
    end
  end

  describe('#create_ticket') do
    it('returns a persisted ticket') do
      expect(lottery.create_ticket).to be_persisted
    end

    it('returns a ticket belonging to the lottery') do
      ticket = lottery.create_ticket
      expect(ticket.lottery).to eq(lottery)
    end

    it('returns a ticket where the ticket#number is set to the largest existing ticketr number belonging to the lottery + 1') do
      lottery.create_ticket(number: 300)
      lottery.create_ticket(number: 13)
      Lottery.create!(event_date: Time.zone.today).create_ticket(number: 999)
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

    it('raises an exception when the ticket cannot be created') do
      expect { lottery.create_ticket(number: 0) }.to raise_exception(ActiveRecord::RecordInvalid)
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
      Lottery.create!(event_date: Time.zone.today).create_ticket(
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
      Lottery.create!(event_date: Time.zone.today).create_ticket(drawn_position: 1)
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
      Lottery.create!(event_date: Time.zone.today).create_ticket(drawn_position: 1)
      expect(lottery.last_drawn_ticket).to be_nil
    end
  end

  describe('#draw') do
    it('raises an exception when the ticket has already been drawn') do
      ticket = lottery.create_ticket(drawn_position: 13)
      expect { lottery.draw(ticket: ticket) }.to raise_exception(ArgumentError, /Ticket has already been drawn/)
    end

    context('when the first ticket is drawn') do
      it('assigns the ticket to the prize with prize#nth_before_last == nil belonging to the lottery') do
        prize = lottery.prizes.create!(nth_before_last: nil, amount: 1.0, draw_order: 1)
        Lottery.create!(event_date: Time.zone.today).prizes.create!(nth_before_last: nil, amount: 1.0, draw_order: 1)
        ticket = lottery.create_ticket

        expect { lottery.draw(ticket: ticket) }.to change { prize.reload.ticket }.from(nil).to(ticket)
      end

      it('does not assign the ticket to the prize when there are no prizes with prize#nth_before_last = nil belonging to the lottery') do
        prize = lottery.prizes.create!(nth_before_last: 0, amount: 1.0, draw_order: 1)
        Lottery.create!(event_date: Time.zone.today).prizes.create!(nth_before_last: nil, amount: 1.0, draw_order: 1)
        ticket = lottery.create_ticket

        expect { lottery.draw(ticket: ticket) }
          .not_to(change { prize.reload.ticket })
      end
    end

    context('when a ticket is drawn and it is not the first one to be drawn') do
      it('assigns the ticket to the prize with prize#nth_before_last == number of dropped of tickets - currently drawn position') do
        prize = lottery.prizes.create!(nth_before_last: 0, amount: 1.0, draw_order: 2)
        Lottery.create!(event_date: Time.zone.today).prizes.create!(nth_before_last: 0, amount: 1.0, draw_order: 2)
        lottery.create_ticket(dropped_off: true, drawn_position: 1)
        ticket = lottery.create_ticket(dropped_off: true)

        expect { lottery.draw(ticket: ticket) }.to change { prize.reload.ticket }.from(nil).to(ticket)
      end

      it('does not assign the ticket to the prize when there are no prizes with prize#nth_before_last == number of dropped of tickets - currently drawn position') do
        prize = lottery.prizes.create!(nth_before_last: 2, amount: 1.0, draw_order: 2)
        Lottery.create!(event_date: Time.zone.today).prizes.create!(nth_before_last: 0, amount: 1.0, draw_order: 2)
        lottery.create_ticket(dropped_off: true, drawn_position: 1)
        ticket = lottery.create_ticket(dropped_off: true)

        expect { lottery.draw(ticket: ticket) }
          .not_to(change { prize.reload.ticket })
      end
    end

    it('persists ticket#drawn_position to the largest ticket#drawn_position belonging to the lottery + 1') do
      lottery.create_ticket(drawn_position: 13)
      lottery.create_ticket(drawn_position: 6)
      Lottery.create!(event_date: Time.zone.today).create_ticket(drawn_position: 21)

      ticket = lottery.create_ticket
      expect { lottery.draw(ticket: ticket) }.to change { ticket.reload.drawn_position }.to(14)
    end

    it('delegates to DrawnTicketBroadcastJob.perform_later') do
      ticket = lottery.create_ticket
      expect(DrawnTicketBroadcastJob).to receive(:perform_later).with(lottery_id: lottery.id)
      lottery.draw(ticket: ticket)
    end

    it('returns true on success') do
      ticket = lottery.create_ticket
      expect(lottery.draw(ticket: ticket)).to be(true)
    end

    it('leaves ticket#prize set to nil when the ticket raises an exception') do
      ticket = lottery.create_ticket
      prize = lottery.prizes.create!(nth_before_last: nil, amount: 1.0, draw_order: 1)

      expect(ticket).to receive(:update!).and_raise('Some error')

      expect { lottery.draw(ticket: ticket) }.to raise_exception('Some error')
      expect(prize.reload.ticket).to be_nil
    end

    it('leaves ticket#drawn_position set to nil when the prize raises an exception') do
      ticket = lottery.create_ticket
      lottery.prizes.create!(nth_before_last: nil, amount: 1.0, draw_order: 1)

      expect_any_instance_of(Prize).to receive(:update!).and_raise('Some error')

      expect { lottery.draw(ticket: ticket) }.to raise_exception('Some error')
      expect(ticket.reload.drawn_position).to be_nil
    end
  end

  describe('#return_last_drawn_ticket') do
    context('when ticket#last_drawn_ticket is nil') do
      it('raises an exception') do
        expect { lottery.return_last_drawn_ticket }.to raise_exception(ArgumentError, /The lottery contains no drawn tickets/)
      end
    end

    context('when ticket#last_drawn_ticket is present') do
      before(:each) do
        ticket = lottery.create_ticket(dropped_off: true)
        lottery.prizes.create!(nth_before_last: nil, amount: 1.0, draw_order: 1)
        lottery.draw(ticket: ticket)
      end

      it('sets ticket#drawn_position to nil') do
        ticket = lottery.last_drawn_ticket
        expect { lottery.return_last_drawn_ticket }
          .to change { ticket.reload.drawn_position }.to(nil)
      end

      it('sets ticket#prize to nil') do
        ticket = lottery.last_drawn_ticket
        expect { lottery.return_last_drawn_ticket }
          .to change { ticket.reload.prize }.to(nil)
      end

      it('delegates to DrawnTicketBroadcastJob.perform_later') do
        expect(DrawnTicketBroadcastJob).to receive(:perform_later).with(lottery_id: lottery.id)
        lottery.return_last_drawn_ticket
      end

      it('maintains the relationship ticket#prize when ticket#update! raises an exception') do
        ticket = lottery.last_drawn_ticket
        expect_any_instance_of(Ticket).to receive(:update!).and_raise('Some error')
        expect { lottery.return_last_drawn_ticket }.to raise_exception('Some error')
        expect(ticket.reload.prize).to be_present
      end

      it('maintains the attribute ticket#drawn_position when prize#update! raises an exception') do
        ticket = lottery.last_drawn_ticket
        expect_any_instance_of(Prize).to receive(:update!).and_raise('Some error')
        expect { lottery.return_last_drawn_ticket }.to raise_exception('Some error')
        expect(ticket.reload.drawn_position).to be_present
      end
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
      expect(new_lottery.errors[:ticket_price]).to include('must be greater than 0')
    end

    it('requires :ticket_price to be less than 10_000 when attribute present') do
      new_lottery = Lottery.new(ticket_price: 10_000)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:ticket_price]).to include('must be less than 10000')
    end

    it('does not validate :ticket_price when attribute is nil') do
      new_lottery = Lottery.new(ticket_price: nil)
      new_lottery.valid?
      expect(new_lottery.errors).not_to include(:ticket_price)
    end

    it('requires :meal_voucher_price to be greater than 0 when attribute present') do
      new_lottery = Lottery.new(meal_voucher_price: 0)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:meal_voucher_price]).to include('must be greater than 0')
    end

    it('requires :meal_voucher_price to be less than 10_000 when attribute present') do
      new_lottery = Lottery.new(meal_voucher_price: 10_000)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:meal_voucher_price]).to include('must be less than 10000')
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
