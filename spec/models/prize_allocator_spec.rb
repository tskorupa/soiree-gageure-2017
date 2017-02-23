require 'rails_helper'

RSpec.describe(PrizeAllocator, type: :model) do
  before(:each) do
    @lottery = Lottery.create!(event_date: Date.today)
    @prize_1 = create_prize!(lottery: @lottery, draw_order: 1, nth_before_last: nil)
    @prize_2 = create_prize!(lottery: @lottery, draw_order: 2, nth_before_last: 10)
    @prize_3 = create_prize!(lottery: @lottery, draw_order: 3, nth_before_last: 1)

    (1..15).each do |i|
      create_ticket!(lottery: @lottery, number: 16 - i, drawn_position: i)
    end
  end

  context('#allocate_prize') do
    it('returns a prize when the position is 1') do
      expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: 1)).to eq(@prize_1)
    end

    it('returns a prize when the position is 2..9 and 11..14') do
      [*(2..9).to_a, *(11..14)].each do |position|
        expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: position)).to be_nil
      end
    end

    it('returns a prize when the position is 10') do
      expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: 10)).to eq(@prize_2)
    end

    it('returns a prize when the position is lottery#num_tickets_in_draw') do
      expect(PrizeAllocator.allocate_prize(lottery: @lottery, position: 15)).to eq(@prize_3)
    end

    it('prefers a prize with nth_before_last: nil over nth_before_last: 1 when there is only one ticket in the lottery') do
      lottery = Lottery.create!(event_date: Date.tomorrow)
      prize = create_prize!(lottery: lottery, draw_order: 1, nth_before_last: nil)
      create_prize!(lottery: lottery, draw_order: 2, nth_before_last: 1)
      create_ticket!(lottery: lottery, number: 1, drawn_position: nil)
      expect(PrizeAllocator.allocate_prize(lottery: lottery, position: 1)).to eq(prize)
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
