# frozen_string_literal: true
class TicketRegistrationsIndex
  include Enumerable

  def initialize(lottery:, tickets:, number_filter:)
    @lottery = lottery
    @tickets = tickets
    @number_filter = number_filter
  end

  attr_reader :number_filter

  def warn?
    lottery.locked?
  end

  def warning_notice
    return unless warn?
    I18n.t('warning_notice')
  end

  def warning_message
    return unless warn?
    I18n.t('ticket_registrations.warning.message')
  end

  def tickets_to_display?
    tickets.any?
  end

  def each
    tickets.each_with_index do |ticket, index|
      number = index + 1
      row = TicketPresenter.new(
        ticket: ticket,
        row_number: number,
      )

      yield row
    end
  end

  def no_tickets_message
    return if tickets_to_display?

    if number_filter.present?
      I18n.t(
        'ticket_registrations.index.no_tickets_with_number',
        number_filter: number_filter,
      )
    else
      I18n.t('ticket_registrations.index.no_tickets')
    end
  end

  private

  attr_reader :lottery, :tickets
end
