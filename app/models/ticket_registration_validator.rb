# frozen_string_literal: true

class TicketRegistrationValidator
  def self.validate(ticket)
    unless ticket.guest
      ticket.errors.add(
        :guest,
        :blank,
        message: I18n.t('ticket_registrations.errors.ticket.guest'),
      )
    end

    if ticket.ticket_type == 'meal_and_lottery' && ticket.table.nil?
      ticket.errors.add(:base, I18n.t('ticket_registrations.errors.table_number'))
    end

    ticket
  end
end
