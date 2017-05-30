# frozen_string_literal: true

class TicketBuilder
  def initialize(lottery:)
    @lottery = lottery
  end

  attr_reader :table_number

  def build(attributes = {})
    ticket_id = attributes.delete(:id)
    seller_name = attributes.delete(:seller_name)
    guest_name = attributes.delete(:guest_name)
    sponsor_name = attributes.delete(:sponsor_name)
    @table_number = attributes.delete(:table_number)

    ticket = find_or_build_ticket(ticket_id, attributes)

    ticket.seller = HandleRelation.find_or_build(
      klass: Seller,
      actual_entity: ticket.seller,
      supplied_full_name: seller_name,
    )
    ticket.guest = HandleRelation.find_or_build(
      klass: Guest,
      actual_entity: ticket.guest,
      supplied_full_name: guest_name,
    )
    ticket.sponsor = HandleRelation.find_or_build(
      klass: Sponsor,
      actual_entity: ticket.sponsor,
      supplied_full_name: sponsor_name,
    )

    ticket.valid?
    if table_number.blank?
      ticket.table = nil
    elsif ticket.table&.number != table_number.to_i
      table = lottery.tables.find_by(number: table_number)
      ticket.table = table
      ticket.errors.add(:base, I18n.t('tables.errors.number')) unless table
    end

    ticket
  end

  private

  attr_reader :lottery

  def find_or_build_ticket(id, attributes)
    scope = lottery.tickets

    ticket = if id.blank?
      scope.new
    else
      scope.includes(:seller, :guest, :sponsor, :table).find(id)
    end
    ticket.assign_attributes(attributes)

    ticket
  end
end
