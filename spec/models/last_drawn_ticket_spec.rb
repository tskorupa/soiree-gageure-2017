# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(LastDrawnTicket, type: :model) do
  include I18nSpecHelper

  describe('#guest_name') do
    it('delegates to ticket#guest_name') do
      @ticket = double(guest_name: 'foo')
      expect(last_drawn_ticket.guest_name).to eq(@ticket.guest_name)
    end
  end

  describe('#number') do
    before(:each) do
      @ticket = double(number: 123)
    end

    it('constructs a string by delegating to ticket#number and prefixing with "Ticket" when the locale is :en') do
      with_locale(:en) do
        expect(last_drawn_ticket.number).to eq('Ticket 123')
      end
    end

    it('constructs a string by delegating to ticket#number and prefixing with "Billet" when the locale is :fr') do
      with_locale(:fr) do
        expect(last_drawn_ticket.number).to eq('Billet 123')
      end
    end
  end

  describe('#ticket_type') do
    it('returns nil when ticket#ticket_type != "lottery_only"') do
      @ticket = double(ticket_type: 'supper_and_lottery')
      expect(last_drawn_ticket.ticket_type).to be_nil
    end

    it('returns "Lottery only" when ticket#ticket_type == "lottery_only" and the locale is :en') do
      @ticket = double(ticket_type: 'lottery_only')
      with_locale(:en) do
        expect(last_drawn_ticket.ticket_type).to eq('Lottery only')
      end
    end

    it('returns "Tirage seulement" when ticket#ticket_type == "lottery_only" and the locale is :fr') do
      @ticket = double(ticket_type: 'lottery_only')
      with_locale(:fr) do
        expect(last_drawn_ticket.ticket_type).to eq('Tirage seulement')
      end
    end
  end

  describe('#table_number') do
    it('returns nil when ticket#table_number is nil') do
      @ticket = double(table_number: nil)
      expect(last_drawn_ticket.table_number).to be_nil
    end

    it('returns "Table 123" when ticket#table_number == 123 and the locale is :en') do
      @ticket = double(table_number: 123)
      with_locale(:en) do
        expect(last_drawn_ticket.table_number).to eq('Table 123')
      end
    end

    it('returns "Table 123" when ticket#table_number == 123 and the locale is :fr') do
      @ticket = double(table_number: 123)
      with_locale(:fr) do
        expect(last_drawn_ticket.table_number).to eq('Table 123')
      end
    end
  end

  describe('#prize_to_display?') do
    it('returns false when ticket#prize_amount is nil') do
      @ticket = double(prize_amount: nil)
      expect(last_drawn_ticket.prize_to_display?).to be(false)
    end

    it('returns true when ticket#prize_amount is not nil') do
      @ticket = double(prize_amount: 33.54)
      expect(last_drawn_ticket.prize_to_display?).to be(true)
    end
  end

  describe('#prize_amount') do
    it('returns nil when ticket#prize_amount is nil') do
      @ticket = double(prize_amount: nil)
      expect(last_drawn_ticket.prize_amount).to be_nil
    end

    it('returns "Prize $124" when ticket#prize_amount == 124 and the locale id :en') do
      @ticket = double(prize_amount: 124)
      with_locale(:en) do
        expect(last_drawn_ticket.prize_amount).to eq('Prize $124')
      end
    end

    it('returns "Prix $123,99" when ticket#prize_amount == 124 and the locale is :fr') do
      @ticket = double(prize_amount: 124)
      with_locale(:fr) do
        expect(last_drawn_ticket.prize_amount).to eq('Prix 124 $')
      end
    end
  end

  private

  def last_drawn_ticket
    LastDrawnTicket.new(ticket: @ticket)
  end
end
