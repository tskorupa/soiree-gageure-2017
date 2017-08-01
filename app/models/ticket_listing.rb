# frozen_string_literal: true
class TicketListing
  extend Memoist
  include Enumerable

  attr_reader :number_filter

  def initialize(ticket_scope:, **options)
    @ticket_scope = ticket_scope
    @number_filter = options.fetch(:number_filter, nil)
  end

  def tickets_to_display?
    tickets.any?
  end
  memoize :tickets_to_display?

  def each
    tickets.each_with_index do |ticket, index|
      row_number = index + 1
      yield TicketPresenter.new(ticket: ticket, row_number: row_number)
    end
  end

  private

  attr_reader :ticket_scope

  def tickets
    requested_tickets = ticket_scope.includes(:seller, :guest, :sponsor, :table).order(:number)
    requested_tickets = requested_tickets.where(number: number_filter) if number_filter.present?
    requested_tickets
  end
  memoize :tickets
end
