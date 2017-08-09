# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketPresenter, type: :model) do
  include I18nHelper

  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:sponsor) do
    Sponsor.create!(full_name: 'Clyde')
  end

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  describe('#ticket_id') do
    it('returns the ticket#id') do
      @ticket = lottery.create_ticket
      expect(ticket_presenter.ticket_id).to eq(@ticket.id)
    end
  end

  describe('#number') do
    it('returns a padded ticket number') do
      @ticket = Ticket.new(number: 3)
      expect(ticket_presenter.number).to eq('003')
    end
  end

  describe('#seller_name') do
    it('returns the seller\'s full name when it is present') do
      @ticket = Ticket.new(seller: seller)
      expect(ticket_presenter.seller_name).to eq(seller.full_name)
    end

    it('returns nil when the seller is missing') do
      @ticket = Ticket.new
      expect(ticket_presenter.seller_name).to be_nil
    end
  end

  describe('#guest_name') do
    it('returns the guest\'s full name when it is present') do
      @ticket = Ticket.new(guest: guest)
      expect(ticket_presenter.guest_name).to eq(guest.full_name)
    end

    it('returns nil when the guest is missing') do
      @ticket = Ticket.new
      expect(ticket_presenter.guest_name).to be_nil
    end
  end

  describe('#sponsor_name') do
    it('returns the sponsor\'s full name when it is present') do
      @ticket = Ticket.new(sponsor: sponsor)
      expect(ticket_presenter.sponsor_name).to eq(sponsor.full_name)
    end

    it('returns nil when the sponsor is missing') do
      @ticket = Ticket.new
      expect(ticket_presenter.sponsor_name).to be_nil
    end
  end

  describe('#state') do
    context('when ticket#state is "reserved"') do
      before(:each) do
        @ticket = Ticket.new(state: 'reserved')
      end

      it('returns "Reserved" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.state).to eq('Reserved')
        end
      end

      it('returns "Réservé" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.state).to eq('Réservé')
        end
      end
    end

    context('when ticket#state is "authorized"') do
      before(:each) do
        @ticket = Ticket.new(state: 'authorized')
      end

      it('returns "Authorized" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.state).to eq('Authorized')
        end
      end

      it('returns "Authorisé" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.state).to eq('Authorisé')
        end
      end
    end

    context('when ticket#state is "paid"') do
      before(:each) do
        @ticket = Ticket.new(state: 'paid')
      end

      it('returns "Paid" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.state).to eq('Paid')
        end
      end

      it('returns "Payé" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.state).to eq('Payé')
        end
      end
    end
  end

  describe('#ticket_type') do
    context('when ticket#ticket_type is "meal_and_lottery"') do
      before(:each) do
        @ticket = Ticket.new(ticket_type: 'meal_and_lottery')
      end

      it('returns "Meal and lottery" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.ticket_type).to eq('Meal and lottery')
        end
      end

      it('returns "Souper et tirage" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.ticket_type).to eq('Souper et tirage')
        end
      end
    end

    context('when ticket#ticket_type is "lottery_only"') do
      before(:each) do
        @ticket = Ticket.new(ticket_type: 'lottery_only')
      end

      it('returns "Lottery only" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.ticket_type).to eq('Lottery only')
        end
      end

      it('returns "Tirage seulement" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.ticket_type).to eq('Tirage seulement')
        end
      end
    end
  end

  describe('#table_number') do
    it('returns the table number when a table is present') do
      @ticket = Ticket.new(table: table)
      expect(ticket_presenter.table_number).to eq(table.number)
    end

    it('returns nil when the table is missing') do
      @ticket = Ticket.new
      expect(ticket_presenter.table_number).to be_nil
    end
  end

  describe('#registration_step') do
    context('when ticket#dropped_off is true') do
      before(:each) do
        @ticket = Ticket.new(dropped_off: true)
      end

      it('returns "Completed" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.registration_step).to eq('Completed')
        end
      end

      it('returns "Complété" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.registration_step).to eq('Complété')
        end
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is true') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: true,
        )
      end

      it('returns "Drop off" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.registration_step).to eq('Drop off')
        end
      end

      it('returns "Mise en boulier" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.registration_step).to eq('Mise en boulier')
        end
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is false and ticket#state is "reserved"') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: false,
          state: 'reserved',
        )
      end

      it('returns "Not paid" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.registration_step).to eq('Not paid')
        end
      end

      it('returns "Non payé" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.registration_step).to eq('Non payé')
        end
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is false and ticket#state is "authorized"') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: false,
          state: 'authorized',
        )
      end

      it('returns "Unregistered" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.registration_step).to eq('Unregistered')
        end
      end

      it('returns "Non payé" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.registration_step).to eq('Non enregistré')
        end
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is false and ticket#state is "paid"') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: false,
          state: 'paid',
        )
      end

      it('returns "Unregistered" when the locale is :en') do
        with_locale(:en) do
          expect(ticket_presenter.registration_step).to eq('Unregistered')
        end
      end

      it('returns "Non payé" when the locale is :fr') do
        with_locale(:fr) do
          expect(ticket_presenter.registration_step).to eq('Non enregistré')
        end
      end
    end
  end

  describe('#registration_label_class') do
    context('when ticket#dropped_off is true') do
      before(:each) do
        @ticket = Ticket.new(dropped_off: true)
      end

      it('returns a default label') do
        expect(ticket_presenter.registration_label_class).to eq('label label-default')
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is true') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: true,
        )
      end

      it('returns an info label') do
        expect(ticket_presenter.registration_label_class).to eq('label label-info')
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is false and ticket#state is "reserved"') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: false,
          state: 'reserved',
        )
      end

      it('returns a danger label') do
        expect(ticket_presenter.registration_label_class).to eq('label label-danger')
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is false and ticket#state is "authorized"') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: false,
          state: 'authorized',
        )
      end

      it('returns a warning label') do
        expect(ticket_presenter.registration_label_class).to eq('label label-warning')
      end
    end

    context('when ticket#dropped_off is false and ticket#registered? is false and ticket#state is "paid"') do
      before(:each) do
        @ticket = Ticket.new(
          dropped_off: false,
          registered: false,
          state: 'paid',
        )
      end

      it('returns a warning label') do
        expect(ticket_presenter.registration_label_class).to eq('label label-warning')
      end
    end
  end

  describe('#model_name') do
    it('delegates #model_name to the ticket') do
      @ticket = Ticket.new
      expect(@ticket).to respond_to(:model_name)
      ticket_presenter.model_name
    end
  end

  describe('#to_param') do
    it('returns the ticket ID') do
      @ticket = lottery.create_ticket
      expect(ticket_presenter.to_param).to eq(@ticket.id)
    end
  end

  private

  def ticket_presenter
    TicketPresenter.new(ticket: @ticket, row_number: 1)
  end
end
