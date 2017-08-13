# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(ResultRow, type: :model) do
  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  describe('#position') do
    it('returns the :position passed in as attribute') do
      @position = double
      expect(result_row.position).to be(@position)
    end
  end

  describe('#prize_amount') do
    it('returns the :prize_amount passed in as attribute') do
      @prize_amount = double
      expect(result_row.prize_amount).to be(@prize_amount)
    end
  end

  describe('#ticket_to_display?') do
    it('returns true when a :ticket has been set as attribute') do
      @ticket = double
      expect(result_row.ticket_to_display?).to be(true)
    end

    it('returns false when no :ticket has been set as attribute') do
      @ticket = nil
      expect(result_row.ticket_to_display?).to be(false)
    end
  end

  describe('#ticket_number') do
    it('returns nil when the :ticket attribute has not been set') do
      @ticket = nil
      expect(result_row.ticket_number).to be_nil
    end

    it('returns a padded ticket number when the :ticket attribute has been set') do
      @ticket = Ticket.new(number: 13)
      expect(result_row.ticket_number).to eq('013')
    end
  end

  describe('#guest_name') do
    it('returns the guest\'s full name when it is present on the ticket') do
      @ticket = Ticket.new(guest: guest)
      expect(result_row.guest_name).to eq(guest.full_name)
    end

    it('returns nil when the guest is undefined on the ticket') do
      @ticket = Ticket.new
      expect(result_row.guest_name).to be_nil
    end
  end

  describe('#model_name') do
    it('delegates #model_name to the ticket') do
      @ticket = Ticket.new
      expect(result_row.model_name).to eq('Ticket')
    end
  end

  describe('#to_param') do
    it('returns the ticket ID') do
      @ticket = lottery.create_ticket
      expect(result_row.to_param).to eq(@ticket.id)
    end
  end

  private

  def result_row
    ResultRow.new(
      position: @position,
      ticket: @ticket,
      prize_amount: @prize_amount,
    )
  end
end
