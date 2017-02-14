require 'rails_helper'

RSpec.describe(TicketRegistrationValidator, type: :model) do
  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  let(:validate_ticket) do
    TicketRegistrationValidator.validate(@ticket)
  end

  before(:each) do
    @ticket = Ticket.create!(
      number: 1,
      lottery: lottery,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      table: table,
    )
  end

  describe('.validate') do
    context('when ticket#guest is nil') do
      before(:each) do
        @ticket.guest = nil
      end

      it('sets the error code :blank on ticket.errors[:guest]') do
        validate_ticket
        expect(@ticket.errors.details[:guest]).to eq([{:error=>:blank}])
      end

      it('sets the error message "Guest name can\'t be blank" on ticket') do
        validate_ticket
        expect(@ticket.errors.full_messages_for(:guest)).to eq(["Guest name can't be blank"])
      end

      it('sets the error message "Le nom de l\'invité doit être spécifié" on ticket') do
        with_locale(:fr) do
          validate_ticket
          expect(@ticket.errors.full_messages_for(:guest)).to eq(["Le nom de l'invité doit être spécifié"])
        end
      end
    end

    context('when ticket#guest is set') do
      before(:each) do
        @ticket.guest = guest
        validate_ticket
      end

      it('sets no error on ticket.errors[:guest]') do
        expect(@ticket.errors).to be_empty
      end
    end

    context('when ticket#ticket_type == "meal_and_lottery" and ticket#table is nil') do
      before(:each) do
        @ticket.ticket_type = 'meal_and_lottery'
        @ticket.table = nil
      end

      it('sets the error message "Table number must be specified" on ticket') do
        validate_ticket
        expect(@ticket.errors.full_messages_for(:base)).to eq(['Table number must be specified'])
      end

      it('sets the error message "Le numéro de table doit être spécifié" on ticket') do
        with_locale(:fr) do
          validate_ticket
          expect(@ticket.errors.full_messages_for(:base)).to eq(['Le numéro de table doit être spécifié'])
        end
      end
    end

    context('when ticket#ticket_type == "lottery_only" and ticket#table is nil') do
      before(:each) do
        @ticket.ticket_type = 'lottery_only'
        @ticket.table = nil
        validate_ticket
      end

      it('sets no error on ticket.errors[:table]') do
        expect(@ticket.errors[:table]).to be_empty
      end
    end
  end

  private

  def with_locale(locale)
    original_locale = I18n.locale
    I18n.locale = locale
    yield
  ensure
    I18n.locale = original_locale
  end
end
