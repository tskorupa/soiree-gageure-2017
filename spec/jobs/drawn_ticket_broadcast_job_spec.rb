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

    it('does not delegate to ActionCable.server.broadcast when lottery#last_drawn_ticket is nil') do
      expect(ActionCable.server).not_to receive(:broadcast)
      expect_any_instance_of(Lottery).to receive(:last_drawn_ticket)
        .and_return(nil)
      perform
    end

    it('delegates to ActionCable.server.broadcast when lottery#last_drawn_ticket == ticket') do
      expected_partial = ApplicationController.renderer.render(
        partial: 'results/drawn_ticket',
        assigns: { ticket: ticket },
      )
      expect(ActionCable.server).to receive(:broadcast)
        .with(
          "lottery_#{lottery.id}_drawn_ticket_channel",
          message: expected_partial,
        )
      expect_any_instance_of(Lottery).to receive(:last_drawn_ticket)
        .and_return(ticket)
      perform
    end
  end
end
