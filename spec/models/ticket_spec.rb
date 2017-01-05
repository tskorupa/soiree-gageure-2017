require 'rails_helper'

RSpec.describe(Ticket, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
    )
  end

  describe('::STATES') do
    it('defines a list of allowed states') do
      expect(Ticket::STATES).to eq(%w( reserved authorized paid ))
    end

    it('returns a frozen array of frozen strings') do
      expect(Ticket::STATES).to be_frozen
      Ticket::STATES.each do |state|
        expect(state).to be_frozen
      end
    end
  end

  describe('#lottery_id') do
    it('is read-only') do
      other_lottery = Lottery.create!(event_date: Date.tomorrow)
      expect do
        ticket.update!(lottery_id: other_lottery.id)
      end.not_to change { ticket.reload.lottery_id }
    end
  end

  describe('#number') do
    it('is indexed') do
      expect(
        ActiveRecord::Base.connection.index_exists?(:tickets, :number),
      ).to be(true)
    end

    it('is unique per lottery') do
      expect(
        ActiveRecord::Base.connection.index_exists?(
          :tickets,
          [:lottery_id, :number],
          unique: true,
        ),
      ).to be(true)
    end
  end

  describe('#state') do
    it('can be any value in Ticket::STATES') do
      Ticket::STATES.each do |state|
        new_ticket = Ticket.new(state: state)
        new_ticket.valid?
        expect(new_ticket.errors[:state]).to be_empty
      end
    end
  end

  describe('#valid?') do
    it ('requires a lottery') do
      new_ticket = Ticket.new
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:lottery]).to include("must exist")
    end

    it('requires :number to be a number') do
      new_ticket = Ticket.new
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:number]).to include('is not a number')
    end

    it('requires :number to be an integer') do
      new_ticket = Ticket.new(number: 3.3)
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:number]).to include('must be an integer')
    end

    it('requires :number to be greater than 0') do
      new_ticket = Ticket.new(number: 0)
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:number]).to include('must be greater than 0')
    end

    it('requires :number to be unique per lottery') do
      new_ticket = Ticket.new(
        lottery: lottery,
        number: ticket.number,
      )
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:number]).to include('has already been taken')
    end

    it('requires :state to be present') do
      new_ticket = Ticket.new
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:state]).to include("is not included in the list")
    end

    it('requires :ticket_type to be present') do
      new_ticket = Ticket.new
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:ticket_type]).to include("is not included in the list")
    end
  end

  describe('#lottery') do
    it('returns the parent lottery') do
      expect(ticket.lottery).to eq(lottery)
    end
  end
end
