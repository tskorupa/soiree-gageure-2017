require 'rails_helper'

RSpec.describe(TicketRegistrationValidator, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
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

    it('passes all validations when ticket#guest is present and ticket#state = :authorized') do
      ticket.guest = guest
      ticket.state = 'authorized'
      validator.validate(ticket)
      expect(ticket.errors).to be_empty
    end

    it('passes all validations when ticket#guest is present and ticket#state = :sold') do
      ticket.guest = guest
      ticket.state = 'sold'
      validator.validate(ticket)
      expect(ticket.errors).to be_empty
    end
  end
end
