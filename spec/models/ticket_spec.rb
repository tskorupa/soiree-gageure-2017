# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Ticket, type: :model) do
  include I18nHelper

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
    )
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  describe('::STATES') do
    it('defines a list of allowed states') do
      expect(Ticket::STATES).to eq(%w(reserved authorized paid))
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
      other_lottery = Lottery.create!(event_date: Time.zone.tomorrow)
      expect do
        ticket.update!(lottery_id: other_lottery.id)
      end.not_to(change { ticket.reload.lottery_id })
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
          %i(lottery_id number),
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

  describe('#drawn_position') do
    before(:each) do
      ticket.update!(drawn_position: 13)
    end

    it('has a unique index on [:lottery_id, :drawn_position]') do
      expect(
        ActiveRecord::Base.connection.index_exists?(
          :tickets,
          %i(lottery_id drawn_position),
          unique: true,
        ),
      ).to be(true)
    end

    it('allows nil as a value') do
      new_ticket = Ticket.new(drawn_position: nil)
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_empty
    end

    it('allows "" as a value') do
      new_ticket = Ticket.new(drawn_position: '')
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_empty
    end

    it('does not allow 0 as a value') do
      new_ticket = Ticket.new(drawn_position: 0)
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_present
    end

    it('does not allow a negative value') do
      new_ticket = Ticket.new(drawn_position: -1)
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_present
    end

    it('does not allow a decimal value') do
      new_ticket = Ticket.new(drawn_position: 0.123)
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_present
    end

    it('does not allow a duplicate value for the same lottery') do
      new_ticket = Ticket.new(
        lottery: lottery,
        drawn_position: ticket.drawn_position,
      )
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_present
    end

    it('allows a duplicate value when the lottery is different') do
      new_ticket = Ticket.new(
        lottery: Lottery.create!(event_date: Time.zone.tomorrow),
        drawn_position: ticket.drawn_position,
      )
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_empty
    end

    it('allows a duplicate value for the same lottery when the value is nil') do
      ticket.update!(drawn_position: nil)
      new_ticket = Ticket.new(
        lottery: ticket.lottery,
        drawn_position: nil,
      )
      new_ticket.valid?
      expect(new_ticket.errors[:drawn_position]).to be_empty
    end
  end

  describe('#can_be_registered?') do
    context('when ticket#registered? is false and ticket#guest is present and ticket#table is required but present') do
      let(:ticket) do
        Ticket.new(
          registered: false,
          guest: guest,
          ticket_type: 'meal_and_lottery',
          table: table,
        )
      end

      it('returns true') do
        expect(ticket.can_be_registered?).to be(true)
      end

      it('adds no errors') do
        ticket.can_be_registered?
        expect(ticket.errors).to be_empty
      end
    end

    context('when ticket#registered? is false and ticket#guest is present and ticket#table is not required but missing') do
      let(:ticket) do
        Ticket.new(
          registered: false,
          guest: guest,
          ticket_type: 'lottery_only',
          table: nil,
        )
      end

      it('returns true') do
        expect(ticket.can_be_registered?).to be(true)
      end

      it('adds no errors') do
        ticket.can_be_registered?
        expect(ticket.errors).to be_empty
      end
    end

    context('when ticket#registered? is true') do
      let(:ticket) do
        Ticket.new(registered: true)
      end

      it('returns false') do
        expect(ticket.can_be_registered?).to be(false)
      end

      it('adds the error "Ticket is already registered" when  the locale is :en') do
        with_locale(:en) do
          ticket.can_be_registered?
          expect(ticket.errors.full_messages_for(:base)).to include('Ticket is already registered')
        end
      end

      it('adds the error "Le billet est déjà enregistré" when the locale is :fr') do
        with_locale(:fr) do
          ticket.can_be_registered?
          expect(ticket.errors.full_messages_for(:base)).to include('Le billet est déjà enregistré')
        end
      end
    end

    context('when ticket#guest is missing') do
      let(:ticket) do
        Ticket.new(guest: nil)
      end

      it('returns false') do
        expect(ticket.can_be_registered?).to be(false)
      end

      it('adds the error "Guest name can\'t be blank" when the locale is :en') do
        with_locale(:en) do
          ticket.can_be_registered?
          expect(ticket.errors.full_messages_for(:guest)).to include('Guest name can\'t be blank')
        end
      end

      it('adds the error "Le nom de l\'invité doit être spécifié" when the locale is :fr') do
        with_locale(:fr) do
          ticket.can_be_registered?
          expect(ticket.errors.full_messages_for(:guest)).to include('Le nom de l\'invité doit être spécifié')
        end
      end
    end

    context('when ticket#table is required but missing') do
      let(:ticket) do
        Ticket.new(ticket_type: 'meal_and_lottery', table: nil)
      end

      it('returns false') do
        expect(ticket.can_be_registered?).to be(false)
      end

      it('adds the error "Table number must be specified" when the locale is :en') do
        with_locale(:en) do
          ticket.can_be_registered?
          expect(ticket.errors.full_messages_for(:base)).to include('Table number must be specified')
        end
      end

      it('adds the error "Le numéro de table doit être spécifié" when the locale is :fr') do
        with_locale(:fr) do
          ticket.can_be_registered?
          expect(ticket.errors.full_messages_for(:base)).to include('Le numéro de table doit être spécifié')
        end
      end
    end
  end

  describe('#register') do
    context('when ticket#registered? is true') do
      let(:ticket) do
        Ticket.new(registered: true)
      end

      it('raises an exception when the locale is :en') do
        with_locale(:en) do
          expect { ticket.register }.to raise_exception(ArgumentError, /Ticket is already registered/)
        end
      end

      it('raises an exception when the locale is :fr') do
        with_locale(:fr) do
          expect { ticket.register }.to raise_exception(ArgumentError, /Le billet est déjà enregistré/)
        end
      end
    end

    it('changes ticket#registered to true when ticket#registered? is false') do
      ticket = lottery.create_ticket(
        registered: false,
        ticket_type: 'lottery_only',
        guest: guest,
      )

      expect { ticket.register }
        .to(change { ticket.reload.registered }.from(false).to(true))
    end
  end

  describe('#valid?') do
    it('requires a lottery') do
      new_ticket = Ticket.new
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:lottery]).to include('must exist')
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
      expect(new_ticket.errors[:state]).to include('is not included in the list')
    end

    it('requires :ticket_type to be present') do
      new_ticket = Ticket.new
      expect(new_ticket).not_to be_valid
      expect(new_ticket.errors[:ticket_type]).to include('is not included in the list')
    end
  end

  describe('#lottery') do
    it('returns the parent lottery') do
      expect(ticket.lottery).to eq(lottery)
    end
  end

  describe('#table') do
    it('returns the parent table') do
      ticket.update!(table: table)
      expect(ticket.reload.table).to eq(table)
    end

    it('increment table#tickets_count when the table is added to the ticket') do
      expect { ticket.update!(table: table) }
        .to(change { table.reload.tickets_count })
    end

    it('decrement table#tickets_count when the table is removed from the ticket') do
      ticket.update!(table: table)
      ticket.reload
      expect { ticket.update!(table: nil) }
        .to(change { table.reload.tickets_count })
    end
  end
end
