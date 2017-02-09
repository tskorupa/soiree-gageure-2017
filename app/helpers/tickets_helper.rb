module TicketsHelper
  def registration_step_label(ticket)
    stage, label_variation = if ticket.dropped_off?
      [:completed, :default]
    elsif ticket.registered?
      [:drop_off, :info]
    elsif ticket.state == 'reserved'
      [:not_paid, :danger]
    else
      [:registration, :warning]
    end

    content_tag(
      :span,
      Ticket.human_attribute_name('ticket.registration_step.%s' % stage),
      class: 'label label-%s' % label_variation,
    )
  end

  def options_for_state_select
    Ticket::STATES.map do |state|
      [
        Ticket.human_attribute_name('state.%s' % state),
        state,
      ]
    end
  end

  def options_for_ticket_type_select
    Ticket::TICKET_TYPES.map do |ticket_type|
      [
        Ticket.human_attribute_name('ticket_type.%s' % ticket_type),
        ticket_type,
      ]
    end
  end
end
