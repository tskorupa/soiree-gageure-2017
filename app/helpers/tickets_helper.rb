module TicketsHelper
  def options_for_state_select
    Ticket::STATES.map do |state|
      [
        Ticket.human_attribute_name('state.%s' % state),
        state,
      ]
    end
  end
end
