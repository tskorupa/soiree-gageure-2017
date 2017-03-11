require 'rails_helper'

RSpec.describe(DrawnTicketBroadcastJob, type: :job) do
  include ActiveJob::TestHelper

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

  describe('#queue_name') do
    it('is in the :default queue') do
      expect(DrawnTicketBroadcastJob.new.queue_name).to eq('default')
    end
  end

  describe('#perform') do
    let(:perform) do
      DrawnTicketBroadcastJob.new.perform(lottery_id: lottery.id)
    end

    it('raises an exception when the :lottery_id does not correspond to a Lottery') do
      expect do
        DrawnTicketBroadcastJob.new.perform(lottery_id: 0)
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it('does not delegate to ActionCable.server.broadcast when no ticket with ticket#drawn_position != nil exists') do
      expect(ActionCable.server).not_to receive(:broadcast)
      perform
    end

    it('picks the ticket with the largest ticket#drawn_position belonging to the lottery') do
      ticket.update!(drawn_position: 2)
      lottery.tickets.create!(
        number: 2,
        state: 'paid',
        ticket_type: 'meal_and_lottery',
        drawn_position: 1,
      )
      Lottery.create!(
        event_date: Date.tomorrow
      ).tickets.create!(
        number: 1,
        state: 'paid',
        ticket_type: 'meal_and_lottery',
        drawn_position: 3,
      )
      expected_partial = ApplicationController.renderer.render(
        partial: 'results/drawn_ticket',
        assigns: { ticket: ticket },
      )
      expect(ActionCable.server).to receive(:broadcast)
        .with(
          "lottery_#{lottery.id}_drawn_ticket_channel",
          message: expected_partial,
        )
      perform
    end
  end
end
