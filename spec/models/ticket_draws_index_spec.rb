# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketDrawsIndex, type: :model) do
  include I18nSpecHelper

  describe('#prize_for_next_drawn_ticket?') do
    it('returns false when there is no prize amount on the next draw') do
      @lottery = double(drawable_tickets: nil, next_prize_amount: nil)
      expect(index.prize_for_next_drawn_ticket?).to be(false)
    end

    it('returns true when there is a prize amount on the next draw') do
      @lottery = double(drawable_tickets: nil, next_prize_amount: 2_000)
      expect(index.prize_for_next_drawn_ticket?).to be(true)
    end
  end

  describe('#prize_for_next_drawn_ticket') do
    it('returns nil when the lottery has no prize amount for the next drawn ticket') do
      @lottery = double(drawable_tickets: nil, next_prize_amount: nil)
      expect(index.prize_for_next_drawn_ticket).to be_nil
    end

    context('when the next drawn ticket will receive a prize') do
      before(:each) do
        @lottery = double(drawable_tickets: nil, next_prize_amount: 2_000)
      end

      it('returns a message when the locale is :en') do
        with_locale(:en) do
          expect(index.prize_for_next_drawn_ticket).to eq('The next drawn ticket merits "$2,000"')
        end
      end

      it('returns a message when the locale is :fr') do
        with_locale(:fr) do
          expect(index.prize_for_next_drawn_ticket).to eq('Le prochain billet tiré se méritera << 2 000 $ >>')
        end
      end
    end
  end

  private

  def index
    TicketDrawsIndex.new(
      lottery: @lottery,
      number_filter: @number_filter,
    )
  end
end
