require 'rails_helper'

RSpec.describe(DrawnTicketUpdater, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      drawn_position: 13,
    )
  end

  let(:prize) do
    Prize.create!(
      lottery: lottery,
      draw_order: 1,
      amount: 250.00,
      ticket: ticket,
    )
  end

  describe('#update') do
    let(:update) do
      DrawnTicketUpdater.update(ticket: ticket)
    end

    before(:each) do
      ticket.update!(drawn_position: 13)
      prize.update!(ticket: ticket)
    end

    it('updates ticket#drawn_position to nil') do
      expect { update }.to change { ticket.reload.drawn_position }.from(13).to(nil)
    end

    it('updates prize#ticket to nil') do
      expect { update }.to change { prize.reload.ticket }.from(ticket).to(nil)
    end

    it('does not update prize#ticket when updating ticket#drawn_position raises an exception') do
      expect_any_instance_of(Ticket).to receive(:update!).and_raise('foo')
      expect { update }.to raise_exception('foo')
      expect(prize.reload.ticket).to eq(ticket)
    end

    it('does not update ticket#drawn_position when updating prize#ticket raises an exception') do
      expect_any_instance_of(Prize).to receive(:update!).and_raise('foo')
      expect { update }.to raise_exception('foo')
      expect(ticket.reload.drawn_position).to eq(13)
    end

    it('delegates to DrawnTicketBroadcastJob.perform_later') do
      expect(DrawnTicketBroadcastJob).to receive(:perform_later).with(lottery_id: lottery.id)
      update
    end
  end
end
