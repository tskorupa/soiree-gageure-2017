# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PrizesHelper, type: :helper) do
  include I18nHelper

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:prize) do
    Prize.create!(
      lottery: lottery,
      draw_order: 1,
      amount: 250.00,
    )
  end

  context('#display_draw_position') do
    it('returns "275" when prize#nth_before_last is 275') do
      prize.nth_before_last = 275
      expect(display_draw_position(prize)).to eq('275')
    end

    context('when locale is :en') do
      it('returns "First announced" when prize#nth_before_last is nil') do
        prize.nth_before_last = nil
        expect(display_draw_position(prize)).to eq('First announced')
      end

      it('returns "Grand prize" when prize#nth_before_last is 0') do
        prize.nth_before_last = 0
        expect(display_draw_position(prize)).to eq('Grand prize')
      end
    end

    context('when locale is :fr') do
      around(:each) do |example|
        with_locale(:fr) { example.run }
      end

      it('returns "Premier annoncé" when prize#nth_before_last is nil') do
        prize.nth_before_last = nil
        expect(display_draw_position(prize)).to eq('Premier annoncé')
      end

      it('returns "Dernier grand prix" when prize#nth_before_last is 0') do
        prize.nth_before_last = 0
        expect(display_draw_position(prize)).to eq('Dernier grand prix')
      end
    end
  end
end
