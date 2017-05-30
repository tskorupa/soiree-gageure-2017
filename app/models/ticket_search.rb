# frozen_string_literal: true

class TicketSearch < ApplicationRecord
  belongs_to(:ticket)

  def self.new(lottery_id:, query:)
    query = query.to_s
    where_attributes = { lottery_id: lottery_id }

    if query.to_i.positive?
      where_attributes[:number] = query
    elsif query.present?
      ticket_ids = TicketSearch.fuzzy_search(query).map(&:ticket_id)
      where_attributes[:id] = ticket_ids
    end

    Ticket.includes(:seller, :guest, :sponsor, :table).where(where_attributes)
  end

  private

  def readonly?
    true
  end
end
