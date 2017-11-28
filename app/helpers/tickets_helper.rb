# frozen_string_literal: true
module TicketsHelper
  def ticket_number_column_name
    t('column_names.number')
  end

  def ticket_type_column_name
    t('column_names.ticket.ticket_type')
  end

  def table_number(ticket)
    ticket.table&.number
  end

  def options_for_state_select
    Ticket::STATES.map do |state|
      [
        Ticket.human_attribute_name(format('state.%s', state)),
        state,
      ]
    end
  end

  def options_for_ticket_type_select
    Ticket::TICKET_TYPES.map do |ticket_type|
      [
        Ticket.human_attribute_name(format('ticket_type.%s', ticket_type)),
        ticket_type,
      ]
    end
  end
end
