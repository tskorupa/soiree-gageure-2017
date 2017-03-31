class Lottery < ApplicationRecord
  has_many :prizes
  has_many :tables
  has_many :tickets

  validates :event_date, presence: true
  validates(
    :ticket_price,
    :meal_voucher_price,
    numericality: { greater_than: 0, less_than: 10_000 },
    allow_nil: true,
  )

  def drawn_tickets
    tickets.where.not(drawn_position: nil)
  end

  def last_drawn_ticket
    drawn_tickets.order(:drawn_position).last
  end

  def draw(ticket:)
    Ticket.transaction do
      drawn_position = drawn_tickets.count + 1
      pick_prize(drawn_position: drawn_position, ticket: ticket)
      ticket.update!(drawn_position: drawn_position)
    end

    DrawnTicketBroadcastJob.perform_later(lottery_id: id)

    true
  end

  private

  def pick_prize(drawn_position:, ticket:)
    Prize.transaction do
      nth_before_last = if drawn_position == 1
        nil
      else
        tickets.where(dropped_off: true).count - drawn_position
      end

      prize = prizes.find_by(nth_before_last: nth_before_last)
      prize.update!(ticket: ticket) if prize
    end
  end
end
