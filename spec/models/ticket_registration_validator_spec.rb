require 'rails_helper'

RSpec.describe(TicketRegistrationValidator, type: :model) do
  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:ticket) do
    Ticket.new(
      guest: guest,
      state: 'paid',
    )
  end

  let(:validator) do
    TicketRegistrationValidator.new
  end

  describe('#validate') do
    it('sets an error on ticket when ticket#guest is nil') do
      ticket.guest = nil
      validator.validate(ticket)
      expect(ticket.errors[:guest]).to be_present
    end

    it('sets an error on ticket when ticket#state is :reserved') do
      ticket.state = 'reserved'
      validator.validate(ticket)
      expect(ticket.errors[:state]).to be_present
    end

    it('sets an error on ticket when ticket#registered = true') do
      ticket.registered = true
      validator.validate(ticket)
      expect(ticket.errors[:registered]).to be_present
    end

    it('passes validations when ticket#guest is set and ticket#state = :authorized') do
      ticket.guest = guest
      ticket.state = 'authorized'
      validator.validate(ticket)
      expect(ticket.errors).to be_empty
    end

    it('passes validations when ticket#guest is set and ticket#state = :paid') do
      ticket.guest = guest
      ticket.state = 'paid'
      validator.validate(ticket)
      expect(ticket.errors).to be_empty
    end
  end
end
