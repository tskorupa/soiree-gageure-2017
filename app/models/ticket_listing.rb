# frozen_string_literal: true
class TicketListing
  extend Memoist
  attr_reader :number_filter

  def initialize(lottery:, **options)
    @lottery = lottery
    @number_filter = options.fetch(:number_filter, nil)
  end

  def tickets_to_display?
    tickets.any?
  end

  def each
    tickets.each_with_index do |ticket, index|
      row_number = index + 1
      yield TicketPresenter.new(ticket: ticket, row_number: row_number)
    end
  end

  private

  attr_reader :lottery

  def tickets
    tickets = lottery.tickets.includes(:seller, :guest, :sponsor, :table).order(:number)
    tickets = tickets.where(number: number_filter) if number_filter.present?
    tickets
  end
  memoize :tickets
end
