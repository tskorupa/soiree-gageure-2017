class TicketBuilder
  def initialize(lottery:)
    @lottery = lottery
  end

  def build(attributes = {})
    ticket_id = attributes.delete(:id)
    seller_name = attributes.delete(:seller_name)
    guest_name = attributes.delete(:guest_name)
    sponsor_name = attributes.delete(:sponsor_name)

    ticket = find_or_build_ticket(ticket_id, attributes)

    ticket.seller = handle_relation(Seller, ticket.seller, seller_name)
    ticket.guest = handle_relation(Guest, ticket.guest, guest_name)
    ticket.sponsor = handle_relation(Sponsor, ticket.sponsor, sponsor_name)

    ticket
  end

  private

  attr_reader :lottery

  def find_or_build_ticket(id, attributes)
    scope = lottery.tickets

    ticket = if id.blank?
      scope.new
    else
      scope.includes(:seller, :guest, :sponsor).find(id)
    end
    ticket.assign_attributes(attributes)

    ticket
  end

  def handle_relation(klass, actual_entity, supplied_full_name)
    return if supplied_full_name.blank?
    return(actual_entity) if actual_entity.try(:full_name) == supplied_full_name

    existing_entity = klass.search(supplied_full_name).first
    return(existing_entity) if existing_entity

    klass.new(full_name: supplied_full_name)
  end
end
