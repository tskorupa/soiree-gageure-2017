require 'rails_helper'

RSpec.describe(Prize, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:prize) do
    Prize.create!(
      lottery: lottery,
      draw_order: 1,
      amount: 250.00,
    )
  end

  describe('#draw_order') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:prizes, :draw_order)).to be(true)
    end
  end

  describe('#valid?') do
    it ('requires a lottery') do
      new_prize = Prize.new
      expect(new_prize).not_to be_valid
      expect(new_prize.errors[:lottery]).to include("must exist")
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
  end

  describe('#lottery') do
    it('returns the parent lottery') do
      expect(prize.lottery).to eq(lottery)
    end
  end
end
