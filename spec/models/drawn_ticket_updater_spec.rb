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

  describe('.update') do
    let(:update) do
      DrawnTicketUpdater.update(lottery: lottery)
    end

    context('when lottery#last_drawn_ticket is nil') do
      before(:each) do
        expect(lottery).to receive(:last_drawn_ticket)
          .and_return(nil)
      end

      it('does not trigger Prize#update!') do
        expect_any_instance_of(Prize).not_to receive(:update!)
        update
      end

      it('does not trigger Ticket#update!') do
        expect_any_instance_of(Ticket).not_to receive(:update!)
        update
      end

      it('does not delegate to DrawnTicketBroadcastJob.perform_later') do
        expect(DrawnTicketBroadcastJob).not_to receive(:perform_later)
        update
      end
    end

    context('when lottery#last_drawn_ticket == ticket') do
      before(:each) do
        ticket.update!(drawn_position: 13)
        expect(lottery).to receive(:last_drawn_ticket)
          .and_return(ticket)
      end

      it('persists ticket#drawn_position = nil') do
        expect { update }.to change { ticket.reload.drawn_position }.to(nil)
      end

      context('when prize#ticket is nil') do
        before(:each) do
          prize.update!(ticket: nil)
        end

        it('does not trigger Prize#update!') do
          expect_any_instance_of(Prize).not_to receive(:update!)
          update
        end
      end

      context('when prize#ticket == ticket') do
        before(:each) do
          prize.update!(ticket: ticket)
        end

        it('persists prize#ticket = nil') do
          expect { update }.to change { prize.reload.ticket }.to(nil)
        end

        it('does not persist prize#ticket = nil if ticket#update! raises an exception') do
          expect_any_instance_of(Ticket).to receive(:update!).and_raise('foo')
          expect { update }.to raise_exception('foo')
          expect(prize.reload.ticket).to eq(ticket)
        end

        it('does not persist ticket#drawn_position = nil if prize#update! raises an exception') do
          expect_any_instance_of(Prize).to receive(:update!).and_raise('foo')
          expect { update }.to raise_exception('foo')
          expect(ticket.reload.drawn_position).not_to be_nil
        end
      end

      it('delegates to DrawnTicketBroadcastJob.perform_later') do
        expect(DrawnTicketBroadcastJob).to receive(:perform_later)
          .with(lottery_id: lottery.id)
        update
      end
    end
  end
end
