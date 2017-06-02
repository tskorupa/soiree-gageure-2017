# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Prize, type: :model) do
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

  describe('#lottery_id') do
    it('is read-only') do
      other_lottery = Lottery.create!(event_date: Time.zone.tomorrow)
      expect { prize.update!(lottery_id: other_lottery.id) }
        .not_to(change { prize.reload.lottery_id })
    end
  end

  describe('#draw_order') do
    it('is indexed') do
      expect(
        ActiveRecord::Base.connection.index_exists?(:prizes, :draw_order),
      ).to be(true)
    end

    it('is unique per lottery') do
      expect(
        ActiveRecord::Base.connection.index_exists?(
          :prizes,
          %i(lottery_id draw_order),
          unique: true,
        ),
      ).to be(true)
    end
  end

  describe('#nth_before_last') do
    before(:each) do
      prize.update!(nth_before_last: 275)
    end

    it('has a unique index on [:lottery_id, :nth_before_last]') do
      expect(
        ActiveRecord::Base.connection.index_exists?(
          :prizes,
          %i(lottery_id nth_before_last),
          unique: true,
        ),
      ).to be(true)
    end

    it('allows nil as a value') do
      new_prize = Prize.new(nth_before_last: nil)
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_empty
    end

    it('allows "" as a value') do
      new_prize = Prize.new(nth_before_last: '')
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_empty
    end

    it('allows 0 as a value') do
      new_prize = Prize.new(nth_before_last: 0)
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_empty
    end

    it('does not allow a negative value') do
      new_prize = Prize.new(nth_before_last: -1)
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_present
    end

    it('does not allow a decimal value') do
      new_prize = Prize.new(nth_before_last: 0.123)
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_present
    end

    it('does not allow a duplicate value for the same lottery') do
      new_prize = Prize.new(
        lottery: lottery,
        nth_before_last: prize.nth_before_last,
      )
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_present
    end

    it('allows a duplicate value when the lottery is different') do
      new_prize = Prize.new(
        lottery: Lottery.create!(event_date: Time.zone.tomorrow),
        nth_before_last: prize.nth_before_last,
      )
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_empty
    end

    it('allows a duplicate value for the same lottery when the value is nil') do
      prize.update!(nth_before_last: nil)
      new_prize = Prize.new(
        lottery: prize.lottery,
        nth_before_last: nil,
      )
      new_prize.valid?
      expect(new_prize.errors[:nth_before_last]).to be_empty
    end

    context('locale is :en') do
      it('sets an error message when :nth_before_last is a negative value') do
        new_prize = Prize.new(nth_before_last: -1)
        new_prize.valid?
        expect(new_prize.errors.full_messages_for(:nth_before_last)).to eq(['Nth before last must be greater than or equal to 0'])
      end

      it('sets an error message when :nth_before_last is not an integer') do
        new_prize = Prize.new(nth_before_last: 0.123)
        new_prize.valid?
        expect(new_prize.errors.full_messages_for(:nth_before_last)).to eq(['Nth before last must be an integer'])
      end

      it('sets an error message when the value has already been taken for the same lottery') do
        new_prize = Prize.new(
          lottery: lottery,
          nth_before_last: prize.nth_before_last,
        )
        new_prize.valid?
        expect(new_prize.errors.full_messages_for(:nth_before_last)).to eq(['Nth before last has already been taken'])
      end
    end

    context('locale is :fr') do
      around(:each) do |example|
        with_locale(:fr) do
          example.run
        end
      end

      it('sets an error message when :nth_before_last is a negative value') do
        new_prize = Prize.new(nth_before_last: -1)
        new_prize.valid?
        expect(new_prize.errors.full_messages_for(:nth_before_last)).to eq(['Le n-ième avant dernier doit être au minimum 0'])
      end

      it('sets an error message when :nth_before_last is not an integer') do
        new_prize = Prize.new(nth_before_last: 0.123)
        new_prize.valid?
        expect(new_prize.errors.full_messages_for(:nth_before_last)).to eq(['Le n-ième avant dernier doit être un nombre entier'])
      end

      it('sets an error message when the value has already been taken for the same lottery') do
        new_prize = Prize.new(
          lottery: lottery,
          nth_before_last: prize.nth_before_last,
        )
        new_prize.valid?
        expect(new_prize.errors.full_messages_for(:nth_before_last)).to eq(['Le n-ième avant dernier a déjà été assigné'])
      end
    end
  end

  describe('#valid?') do
    it('requires a lottery') do
      new_prize = Prize.new
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:lottery]).to include('must exist')
    end

    it('requires :draw_order to be a number') do
      new_prize = Prize.new
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:draw_order]).to include('is not a number')
    end

    it('requires :draw_order to be an integer') do
      new_prize = Prize.new(draw_order: 3.3)
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:draw_order]).to include('must be an integer')
    end

    it('requires :draw_order to be greater than 0') do
      new_prize = Prize.new(draw_order: 0)
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:draw_order]).to include('must be greater than 0')
    end

    it('requires :draw_number to be unique per lottery') do
      new_prize = Prize.new(
        lottery: lottery,
        draw_order: prize.draw_order,
        amount: 100,
      )
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:draw_order]).to include('has already been taken')
    end

    it('requires :amount to be a number') do
      new_prize = Prize.new
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:amount]).to include('is not a number')
    end

    it('requires :amount to be greater than 0') do
      new_prize = Prize.new(amount: 0)
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:amount]).to include('must be greater than 0')
    end

    it('requires :amount to be less than 10_000') do
      new_prize = Prize.new(amount: 10_000)
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:amount]).to include('must be less than 10000')
    end
  end

  describe('#lottery') do
    it('returns the parent lottery') do
      expect(prize.lottery).to eq(lottery)
    end
  end
end
