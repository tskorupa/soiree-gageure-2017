# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(DrawnTicketBroadcastJob, type: :job) do
  include ActiveJob::TestHelper

  let(:create_lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  describe('#queue_name') do
    it('is in the :default queue') do
      expect(DrawnTicketBroadcastJob.new.queue_name).to eq('default')
    end
  end

  describe('#perform') do
    it('raises an exception when the :lottery_id does not correspond to a Lottery') do
      expect { DrawnTicketBroadcastJob.new.perform(lottery_id: 0) }
        .to(raise_exception(ActiveRecord::RecordNotFound))
    end

    it('delegates to ActionCable.server.broadcast when the lottery has no drawn tickets') do
      lottery = create_lottery

      expect_action_cable_broadcast(lottery)
      DrawnTicketBroadcastJob.new.perform(lottery_id: lottery.id)
    end

    it('delegates to ActionCable.server.broadcast when the lottery has a drawn ticket') do
      lottery = create_lottery
      ticket = lottery.create_ticket
      lottery.draw(ticket: ticket)

      expect_action_cable_broadcast(lottery)
      DrawnTicketBroadcastJob.new.perform(lottery_id: lottery.id)
    end
  end

  private

  def expect_action_cable_broadcast(lottery)
    channel = expected_broadcast_channel(lottery)
    message = expected_broadcast_message(lottery)

    expect(ActionCable.server)
      .to(receive(:broadcast))
      .with(channel, message: message)
  end

  def expected_broadcast_channel(lottery)
    format('lottery_%i_drawn_ticket_channel', lottery.id)
  end

  def expected_broadcast_message(lottery)
    results_index = ResultsIndex.new(lottery: lottery)

    ApplicationController.renderer.render(
      partial: 'results/drawn_ticket',
      locals: { results_index: results_index },
    )
  end
end
