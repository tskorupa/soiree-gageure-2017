# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(TicketBuilder, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
    )
  end

  let(:ticket_builder) do
    TicketBuilder.new(lottery: lottery)
  end

  it('#table_number') do
    expect(ticket_builder.table_number).to be_nil
  end

  describe('#build') do
    it('assigns the attribute #table_number when :table_number is provided') do
      builder = ticket_builder
      builder.build(table_number: 1)
      expect(builder.table_number).to eq(1)
    end

    it('returns a validated ticket') do
      ticket = ticket_builder.build
      expect(ticket.errors).to be_present
    end

    context('when :id is defined in the arguments') do
      before(:each) do
        @attributes = { id: ticket.id }
      end

      context('when ticket#table is defined') do
        before(:each) do
          ticket.update!(table: table)
        end

        let(:other_table) do
          Table.create!(
            lottery: lottery,
            number: 2,
            capacity: 6,
          )
        end

        let(:table_from_different_lottery) do
          Table.create!(
            lottery: Lottery.create!(event_date: Time.zone.today),
            number: 3,
            capacity: 6,
          )
        end

        it('assigns ticket#table to nil when :table_number is empty') do
          ticket = ticket_builder.build(@attributes.merge(table_number: ''))
          expect(ticket.table).to be_nil
        end

        it('leaves ticket#table as-is when :table_number corresponds to the table that is already defined on the ticket') do
          ticket = ticket_builder.build(@attributes.merge(table_number: table.number))
          expect(ticket.table).to eq(table)
        end

        it('assigns ticket#table to nil when :table_number corresponds to a table that does not belong to the lottery') do
          ticket = ticket_builder.build(
            @attributes.merge(table_number: table_from_different_lottery.number),
          )
          expect(ticket.table).to be_nil
        end

        it('adds an error to ticket#errors when :table_number corresponds to a table that does not belong to the lottery') do
          ticket = ticket_builder.build(
            @attributes.merge(table_number: table_from_different_lottery.number),
          )
          expect(ticket.errors[:base]).to eq(['Ticket number is invalid'])
        end

        it('assigns ticket#table when :table_number corresponds to a different table that belongs to the lottery') do
          ticket = ticket_builder.build(@attributes.merge(table_number: other_table.number))
          expect(ticket.table).to eq(other_table)
        end
      end
    end

    it('returns a new ticket scoped to lottery when an :id is not provided') do
      actual_ticket = ticket_builder.build
      expect(actual_ticket).to be_new_record
      expect(actual_ticket.lottery).to eq(lottery)
    end

    it('returns an existing ticket belonging to the lottery when an :id is provided') do
      actual_ticket = ticket_builder.build(id: ticket.id)
      expect(actual_ticket).not_to be_new_record
      expect(actual_ticket.lottery).to eq(lottery)
    end

    it('raises an exception when the ticket with the given :id is not found') do
      expect do
        ticket_builder.build(id: 0)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it('raises an exception when the ticket with the given :id does not belong to the lottery') do
      other_lottery = Lottery.create!(event_date: Time.zone.tomorrow)
      ticket_builder = TicketBuilder.new(lottery: other_lottery)

      expect do
        ticket_builder.build(id: ticket.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it('returns a new ticket with ticket#number assigned when an :id is not provided and a :number is provided') do
      actual_ticket = ticket_builder.build(number: 101)
      expect(actual_ticket).to be_new_record
      expect(actual_ticket.number).to eq(101)
    end

    it('returns an existing ticket with ticket#number assigned when an :id is provided and a :number is provided') do
      actual_ticket = ticket_builder.build(id: ticket.id, number: 101)
      expect(actual_ticket).not_to be_new_record
      expect(actual_ticket.number).to eq(101)
    end

    it('returns a new ticket with ticket#state assigned when an :id is not provided and a :state is provided') do
      actual_ticket = ticket_builder.build(state: 'paid')
      expect(actual_ticket).to be_new_record
      expect(actual_ticket.state).to eq('paid')
    end

    it('returns an existing ticket with ticket#state assigned when an :id is provided and a :state is provided') do
      actual_ticket = ticket_builder.build(id: ticket.id, state: 'paid')
      expect(actual_ticket).not_to be_new_record
      expect(actual_ticket.state).to eq('paid')
    end

    it('returns a new ticket with ticket#ticket_type assigned when an :id is not provided and a :ticket_type is provided') do
      actual_ticket = ticket_builder.build(ticket_type: 'lottery_only')
      expect(actual_ticket).to be_new_record
      expect(actual_ticket.ticket_type).to eq('lottery_only')
    end

    it('returns an existing ticket with ticket#ticket_type assigned when an :id is provided and a :ticket_type is provided') do
      actual_ticket = ticket_builder.build(id: ticket.id, ticket_type: 'lottery_only')
      expect(actual_ticket).not_to be_new_record
      expect(actual_ticket.ticket_type).to eq('lottery_only')
    end

    it('returns a new ticket with the seller set to nil when an :id is not provided and the :seller_name is blank') do
      [nil, ''].each do |seller_name|
        actual_ticket = ticket_builder.build(seller_name: seller_name)
        expect(actual_ticket).to be_new_record
        expect(actual_ticket.seller).to be_nil
      end
    end

    it('returns an existing ticket with the seller set to nil when an :id is provided and the :seller_name is blank') do
      [nil, ''].each do |seller_name|
        actual_ticket = ticket_builder.build(id: ticket.id, seller_name: seller_name)
        expect(actual_ticket).not_to be_new_record
        expect(actual_ticket.seller).to be_nil
      end
    end

    it('returns an existing ticket with the seller unchanged when an :id is provided and the :seller_name matches the current seller') do
      ticket.seller = seller
      actual_ticket = ticket_builder.build(id: ticket.id, seller_name: seller.full_name)
      expect(actual_ticket).not_to be_new_record
      expect(actual_ticket.seller).not_to be_new_record
      expect(actual_ticket.seller).to eq(seller)
    end

    it('returns a new ticket tied to an existing seller when an :id is not provided and the :seller_name matches an existing seller') do
      actual_ticket = ticket_builder.build(seller_name: seller.full_name)
      expect(actual_ticket).to be_new_record
      expect(actual_ticket.seller).not_to be_new_record
      expect(actual_ticket.seller).to eq(seller)
    end

    it('returns an existing ticket set to an existing seller when an :id is provided and the :seller_name matches an existing seller') do
      actual_ticket = ticket_builder.build(id: ticket.id, seller_name: seller.full_name)
      expect(actual_ticket).not_to be_new_record
      expect(actual_ticket.seller).not_to be_new_record
      expect(actual_ticket.seller).to eq(seller)
    end

    it('returns a new ticket set to a new seller when an :id is not provided and the :seller_name does not match an existing seller') do
      actual_ticket = ticket_builder.build(seller_name: 'Pip')
      expect(actual_ticket).to be_new_record
      expect(actual_ticket.seller).to be_new_record
      expect(actual_ticket.seller.full_name).to eq('Pip')
    end

    it('returns an existing ticket set to a new seller when an :id is provided and the :seller_name does not match an existing seller') do
      actual_ticket = ticket_builder.build(id: ticket.id, seller_name: 'Pip')
      expect(actual_ticket).not_to be_new_record
      expect(actual_ticket.seller).to be_new_record
      expect(actual_ticket.seller.full_name).to eq('Pip')
    end

    it('runs same tests as for seller but for guest') do
      skip
    end

    it('runs same tests as for seller but for sponsor') do
      skip
    end
  end
end
