# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketPdf, type: :model) do
  include I18nSpecHelper

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  let(:ticket) do
    Ticket.create!(
      number: 1,
      lottery: lottery,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      table: table,
      guest: guest,
    )
  end

  let(:ticket_pdf) do
    TicketPdf.new(ticket: ticket)
  end

  context('#filename') do
    it('returns "ticket_6.pdf" when the ticket#number == 6') do
      ticket.number = 6
      assert_equal(
        'ticket_6.pdf',
        ticket_pdf.filename,
      )
    end

    it('returns "billet_6.pdf" when the ticket#number == 6 and I18n.locale == :fr') do
      with_locale(:fr) do
        ticket.number = 6
        assert_equal(
          'billet_6.pdf',
          ticket_pdf.filename,
        )
      end
    end
  end

  context('#render') do
    it('returns not nil') do
      expect(ticket_pdf.render).to be_present
    end
  end
end
