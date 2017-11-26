# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(ResultsIndex, type: :model) do
  include I18nSpecHelper

  describe('#lottery_id') do
    it('delegates to lottery#id') do
      @lottery = double(id: 123)
      expect(results_index.lottery_id).to eq(@lottery.id)
    end
  end

  describe('#title') do
    it('returns "Last drawn ticket" when the locale is :en') do
      with_locale(:en) do
        expect(results_index.title).to eq('Last drawn ticket')
      end

      with_locale(:fr) do
        expect(results_index.title).to eq('Dernier billet tiré')
      end
    end
  end

  describe('#ticket_to_display?') do
    it('returns true when lottery#last_drawn_ticket is not nil') do
      @lottery = double(last_drawn_ticket: double)
      expect(results_index.ticket_to_display?).to be(true)
    end

    it('returns false when lottery#last_drawn_ticket is nil') do
      @lottery = double(last_drawn_ticket: nil)
      expect(results_index.ticket_to_display?).to be(false)
    end
  end

  describe('#ticket') do
    it('returns nil when lottery#last_drawn_ticket is nil') do
      @lottery = double(last_drawn_ticket: nil)
      expect(results_index.ticket).to be_nil
    end

    it('returns a ticket when lottery#last_drawn_ticket is not nil') do
      @lottery = double(last_drawn_ticket: double)
      expect(results_index.ticket).to be_present
    end
  end

  describe('#no_ticket_message') do
    it('returns "No tickets were drawn." when the locale is :en') do
      with_locale(:en) do
        expect(results_index.no_ticket_message).to eq('No tickets were drawn.')
      end
    end

    it('returns "Aucun billet n\'a été tiré." when the locale is :fr') do
      with_locale(:fr) do
        expect(results_index.no_ticket_message).to eq('Aucun billet n\'a été tiré.')
      end
    end
  end

  private

  def results_index
    ResultsIndex.new(lottery: @lottery)
  end
end
