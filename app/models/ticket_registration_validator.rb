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
    ) unless %w(authorized paid).include?(ticket.state)

    ticket.errors.add(
      :registered,
      :invalid,
      message: I18n.translate('ticket_registrations.errors.ticket.registered'),
    ) if ticket.registered?
  end
end
