# frozen_string_literal: true
class DrawnTicketBroadcastJob < ApplicationJob
  queue_as :default

  def perform(lottery_id:)
    lottery = Lottery.find(lottery_id)

    channel = format('lottery_%i_drawn_ticket_channel', lottery.id)
    message = broadcast_message(lottery)

    ActionCable.server.broadcast(channel, message: message)
  end

  private

  def broadcast_message(lottery)
    results_index = ResultsIndex.new(lottery: lottery)

    ApplicationController.renderer.render(
      partial: 'results/drawn_ticket',
      locals: { results_index: results_index },
    )
  end
end
