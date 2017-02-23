require 'rails_helper'

RSpec.describe(TicketDrawUpdater, type: :model) do
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

  let(:prize) do
    Prize.create!(
      lottery: lottery,
      draw_order: 1,
      amount: 250.00,
    )
  end

  describe('#update') do
    let(:update) do
      TicketDrawUpdater.new(ticket: ticket).update
    end

    it('updates ticket#drawn_position with the value of PositionAllocator.allocate_position') do
      expect(PositionAllocator).to receive(:allocate_position).and_return(6)
      expect { update }.to change { ticket.reload.drawn_position }.from(nil).to(6)
    end

    it('updates prize#ticket with the value of PrizeAllocator.allocate_prize') do
      expect(PrizeAllocator).to receive(:allocate_prize).and_return(prize)
      expect { update }.to change { prize.reload.ticket }.from(nil).to(ticket)
    end

    it('does not update prize#ticket when updating ticket#drawn_position raises an exception') do
      expect_any_instance_of(Ticket).to receive(:update!).and_raise('foo')
      expect(PrizeAllocator).to receive(:allocate_prize).and_return(prize)
      expect { update }.to raise_exception('foo')
      expect(prize.reload.ticket).to be_nil
    end

    it('does not update ticket#drawn_position when updating prize#ticket raises an exception') do
      expect_any_instance_of(Prize).to receive(:update!).and_raise('foo')
      expect(PrizeAllocator).to receive(:allocate_prize).and_return(prize)
      expect(PositionAllocator).to receive(:allocate_position).and_return(6)
      expect { update }.to raise_exception('foo')
      expect(ticket.reload.drawn_position).to be_nil
    end
  end
end
