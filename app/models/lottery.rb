# frozen_string_literal: true

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

  def create_ticket(attributes = {})
    number = attributes.fetch(:number) { next_ticket_number }
    tickets.create!(
      number: number,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
      **attributes,
    )
  end

  def registerable_tickets
    tickets.where(registered: false)
      .where.not(state: 'reserved')
  end

  def drawable_tickets
    tickets.where(
      dropped_off: true,
      drawn_position: nil,
    )
  end

  def drawn_tickets
    tickets.where.not(drawn_position: nil)
  end

  def last_drawn_ticket
    drawn_tickets.order(:drawn_position).last
  end

  def draw(ticket:)
    raise(ArgumentError, 'Ticket has already been drawn') if ticket.drawn_position.present?

    Ticket.transaction do
      drawn_position = next_drawn_position
      pick_prize(drawn_position: drawn_position, ticket: ticket)
      ticket.update!(drawn_position: drawn_position)
    end
    DrawnTicketBroadcastJob.perform_later(lottery_id: id)

    true
  end

  def return_last_drawn_ticket
    ticket = last_drawn_ticket
    raise ArgumentError.new(message: 'The lottery contains no drawn tickets') unless ticket

    prize = prizes.find_by(ticket_id: ticket.id)

    Ticket.transaction do
      prize&.update!(ticket_id: nil)
      ticket.update!(drawn_position: nil)
    end

    DrawnTicketBroadcastJob.perform_later(lottery_id: id)

    true
  end

  private

  def next_drawn_position
    drawn_position = last_drawn_ticket&.drawn_position
    drawn_position ||= 0
    drawn_position + 1
  end

  def next_ticket_number
    number = tickets.order(:number).last&.number
    number ||= 0
    number + 1
  end

  def pick_prize(drawn_position:, ticket:)
    Prize.transaction do
      nth_before_last = if drawn_position == 1
        nil
      else
        tickets.where(dropped_off: true).count - drawn_position
      end

      prize = prizes.find_by(nth_before_last: nth_before_last)
      prize&.update!(ticket: ticket)
    end
  end
end
