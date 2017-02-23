require 'rails_helper'

RSpec.describe(PositionAllocator, type: :model) do
  before(:each) do
    @lottery_1 = Lottery.create!(event_date: Date.today)

    @lottery_2 = Lottery.create!(event_date: Date.tomorrow)
    create_ticket!(
      lottery: @lottery_2,
      number: 7,
      drawn_position: 4,
    )
    create_ticket!(
      lottery: @lottery_2,
      number: 9,
      drawn_position: 6,
    )
  end

  context('#allocate_position') do
    it('returns 1 when all tickets belonging to the lottery have drawn_position: nil') do
      expect(PositionAllocator.allocate_position(lottery: @lottery_1)).to eq(1)
    end

    it('returns 3 when two tickets belonging to the lottery have :drawn_position set') do
      expect(PositionAllocator.allocate_position(lottery: @lottery_2)).to eq(3)
    end
  end

  private

  def create_ticket!(attributes)
    Ticket.create!(
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
      **attributes,
    )
  end
end
