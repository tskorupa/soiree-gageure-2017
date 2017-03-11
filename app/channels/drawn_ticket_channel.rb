class DrawnTicketChannel < ApplicationCable::Channel
  def subscribed
    stream_from("lottery_#{params[:lottery_id]}_drawn_ticket_channel")
  end
end
