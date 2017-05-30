# frozen_string_literal: true

module TicketsHelper
  def table_number(ticket)
    @builder&.table_number || ticket.table&.number
  end

  def registration_step_label(ticket)
    stage, label_variation = if ticket.dropped_off?
      %i(completed default)
    elsif ticket.registered?
      %i(drop_off info)
    elsif ticket.state == 'reserved'
      %i(not_paid danger)
    else
      %i(registration warning)
    end

    content_tag(
      :span,
      Ticket.human_attribute_name(format('ticket.registration_step.%s', stage)),
      class: format('label label-%s', label_variation),
    )
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
