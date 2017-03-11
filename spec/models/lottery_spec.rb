require 'rails_helper'

RSpec.describe(Lottery, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  describe('#last_drawn_ticket') do
    before(:each) do
      lottery.tickets.create!(
        number: 1,
        state: 'paid',
        ticket_type: 'meal_and_lottery',
        drawn_position: 13,
      )
      @last_drawn_ticket = lottery.tickets.create!(
        number: 2,
        state: 'paid',
        ticket_type: 'meal_and_lottery',
        drawn_position: 14,
      )
      @other_lottery = Lottery.create!(event_date: Date.tomorrow)
    end

    it('returns nil when all tickets belonging to the lottery have ticket#drawn_position == nil') do
      expect(@other_lottery.last_drawn_ticket).to be_nil
    end

    it('returns the ticket belonging to the lottery with the largest ticket#drawn_position') do
      expect(lottery.last_drawn_ticket).to eq(@last_drawn_ticket)
    end
  end

  describe('#event_date') do
    it('is indexed') do
      expect(ActiveRecord::Base.connection.index_exists?(:lotteries, :event_date)).to be(true)
    end
  end

  describe('#valid?') do
    it('requires :event_date to be present') do
      new_lottery = Lottery.new
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:event_date]).to include("can't be blank")
    end

    it('requires :ticket_price to be greater than 0 when attribute present') do
      new_lottery = Lottery.new(ticket_price: 0)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:ticket_price]).to include("must be greater than 0")
    end

    it('requires :ticket_price to be less than 10_000 when attribute present') do
      new_lottery = Lottery.new(ticket_price: 10_000)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:ticket_price]).to include("must be less than 10000")
    end

    it('does not validate :ticket_price when attribute is nil') do
      new_lottery = Lottery.new(ticket_price: nil)
      new_lottery.valid?
      expect(new_lottery.errors).not_to include(:ticket_price)
    end

    it('requires :meal_voucher_price to be greater than 0 when attribute present') do
      new_lottery = Lottery.new(meal_voucher_price: 0)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:meal_voucher_price]).to include("must be greater than 0")
    end

    it('requires :meal_voucher_price to be less than 10_000 when attribute present') do
      new_lottery = Lottery.new(meal_voucher_price: 10_000)
      expect(new_lottery).not_to be_valid
      expect(new_lottery.errors[:meal_voucher_price]).to include("must be less than 10000")
    end

    it('does not validate :meal_voucher_price when attribute is nil') do
      new_lottery = Lottery.new(meal_voucher_price: nil)
      new_lottery.valid?
      expect(new_lottery.errors).not_to include(:meal_voucher_price)
    end
  end

  describe('#prizes') do
    before(:each) do
      Prize.create!(
        lottery: lottery,
        draw_order: 1,
        amount: 250.00,
      )
    end

    it('returns the prizes belonging to the lottery') do
      expect(lottery.prizes).to eq(Prize.where(lottery_id: lottery.id))
    end
  end

  describe('#tables') do
    before(:each) do
      Table.create!(
        lottery: lottery,
        number: 1,
        capacity: 6,
      )
    end

    it('returns the prizes belonging to the lottery') do
      expect(lottery.prizes).to eq(Prize.where(lottery_id: lottery.id))
    end
  end

  describe('#tickets') do
    it('returns the tickets belonging to the lottery') do
      Ticket.create!(
        number: 1,
        lottery: lottery,
        state: 'reserved',
        ticket_type: 'meal_and_lottery',
      )
      expect(lottery.tickets).to eq(Ticket.where(lottery_id: lottery.id))
    end
  end
end
