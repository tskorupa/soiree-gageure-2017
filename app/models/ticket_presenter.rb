# frozen_string_literal: true
class TicketPresenter
  extend Memoist

  def initialize(ticket:, row_number:)
    @ticket = ticket
    @row_number = row_number
  end

  attr_reader :row_number
  delegate :id, to: :ticket, prefix: :ticket

  def number
    PaddedNumber.pad_number(ticket.number)
  end
  memoize :number

  def seller_name
    ticket.seller&.full_name
  end
  memoize :seller_name

  def guest_name
    ticket.guest&.full_name
  end
  memoize :guest_name

  def sponsor_name
    ticket.sponsor&.full_name
  end
  memoize :sponsor_name

  def state
    formated_state = format('state.%s', ticket.state)
    Ticket.human_attribute_name(formated_state)
  end
  memoize :state

  def ticket_type
    formated_ticket_type = format('ticket_type.%s', ticket.ticket_type)
    Ticket.human_attribute_name(formated_ticket_type)
  end
  memoize :ticket_type

  def table_number
    ticket.table&.number
  end
  memoize :table_number

  def registration_step
    formated_internationalized_step = format('ticket.registration_step.%s', registration)
    Ticket.human_attribute_name(formated_internationalized_step)
  end
  memoize :registration_step

  def registration_label_class
    label_class = case registration
    when :completed then :default
    when :drop_off then :info
    when :not_paid then :danger
    else :warning
    end

    format('label label-%s', label_class)
  end
  memoize :registration_label_class

  delegate :model_name, to: :ticket
  def to_param
    ticket.id
  end

  private

  attr_reader :ticket

  def registration
    if ticket.dropped_off?
      :completed
    elsif ticket.registered?
      :drop_off
    elsif ticket.state == 'reserved'
      :not_paid
    else
      :registration
    end
  end
  memoize :registration
end
