require 'rails_helper'

RSpec.describe(PrizeAllocator, type: :model) do
  before(:each) do
    @lottery = Lottery.create!(event_date: Date.today)
    @prize_1 = create_prize!(lottery: @lottery, draw_order: 1, nth_before_last: nil)
    @prize_2 = create_prize!(lottery: @lottery, draw_order: 2, nth_before_last: 10)
    @prize_3 = create_prize!(lottery: @lottery, draw_order: 3, nth_before_last: 0)

    (1..15).each do |i|
      create_ticket!(lottery: @lottery, number: 16 - i, drawn_position: i)
    end
  end

  context('#allocate_prize') do
    it('returns a prize when the position is 1') do
      expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: 1)).to eq(@prize_1)
    end

    it('returns a prize when the position is 2..4 and 6..14') do
      [*(2..4).to_a, *(6..14)].each do |position|
        expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: position)).to be_nil
      end
    end

    it('returns a prize when the position is 5') do
      expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: 5)).to eq(@prize_2)
    end

    it('returns a prize when the position is lottery#num_tickets_in_draw') do
      expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: 15)).to eq(@prize_3)
    end
  end

  private

  def create_prize!(attributes)
    Prize.create!(amount: 1, **attributes)
  end

  def create_ticket!(attributes)
    Ticket.create!(
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
      **attributes,
      dropped_off: true,
    )
  end
end
