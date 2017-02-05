class TicketRegistrationsController < ApplicationController
  include LotteryLookup

  def index
    @number = params[:number]
    @tickets = unregistered_tickets.order(:number)
    @tickets = @tickets.where(number: @number) if @number.present?

    render(
      'lotteries/lottery_child_index',
      locals: { main_partial: 'ticket_registrations/index' },
    )
  end

  def edit
    return head(:no_content) if @lottery.locked?
    @ticket = unregistered_tickets.find(params[:id])
  end

  def update
    return head(:no_content) if @lottery.locked?

    @ticket = unregistered_tickets.find(params[:id])

    @ticket.guest = HandleRelation.find_or_build(
      klass: Guest,
      actual_entity: @ticket.guest,
      supplied_full_name: params[:guest_name],
    )
    @ticket.assign_attributes(ticket_params)

    TicketRegistrationValidator.new.validate(@ticket)
    return render(:edit) if @ticket.errors.any?

    @ticket.registered = true
    @ticket.save
    redirect_to(lottery_ticket_registrations_path(@lottery))
  end

  private

  def unregistered_tickets
    @lottery.tickets.where(registered: false)
  end

  def ticket_params
    params.require(:ticket).permit(:state)
  end
end
