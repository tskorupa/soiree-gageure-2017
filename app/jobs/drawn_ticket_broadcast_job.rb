# frozen_string_literal: true
class DrawnTicketBroadcastJob < ApplicationJob
  queue_as :default

  def perform(lottery_id:)
    lottery = Lottery.find(lottery_id)

    ticket = lottery.last_drawn_ticket

    channel = format('lottery_%i_drawn_ticket_channel', lottery.id)
    message = broadcast_message(lottery, ticket)

    ActionCable.server.broadcast(channel, message: message)
  end

  private

  def broadcast_message(lottery, ticket)
    locals = { lottery_id: lottery.id }
    locals = locals.merge(
      ticket: LastDrawnTicket.new(ticket: ticket),
    ) if ticket

    ApplicationController.renderer.render(
      partial: 'results/drawn_ticket',
      locals: locals,
    )
  end
end
