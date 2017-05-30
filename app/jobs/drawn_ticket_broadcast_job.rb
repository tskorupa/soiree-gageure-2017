# frozen_string_literal: true

class DrawnTicketBroadcastJob < ApplicationJob
  queue_as :default

  def perform(lottery_id:)
    ticket = Lottery.find(lottery_id).last_drawn_ticket
    return unless ticket

    ActionCable.server.broadcast(
      "lottery_#{lottery_id}_drawn_ticket_channel",
      message: render_result(ticket),
    )
  end

  private

  def render_result(ticket)
    ApplicationController.renderer.render(
      partial: 'results/drawn_ticket',
      assigns: { ticket: ticket },
    )
  end
end
