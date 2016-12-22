class TicketRegistrationValidator < ActiveModel::Validator
  def validate(ticket)
    ticket.errors.add(
      :guest,
      :blank,
      message: I18n.translate('ticket_registrations.errors.ticket.guest'),
    ) unless ticket.guest

    ticket.errors.add(
      :state,
      :inclusion,
      message: I18n.translate('ticket_registrations.errors.ticket.state'),
    ) unless %w(authorized sold).include?(ticket.state)
  end
end
