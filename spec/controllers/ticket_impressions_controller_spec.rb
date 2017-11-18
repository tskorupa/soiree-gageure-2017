# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketImpressionsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 103,
      capacity: 6,
    )
  end

  let(:ticket) do
    create_ticket
  end

  let(:user) do
    User.create!(
      email: 'abc@def.com',
      password: 'foobar',
    )
  end

  it('includes LotteryLookup') do
    expect(controller.class.ancestors).to include(LotteryLookup)
  end

  context('When the user is logged out') do
    describe('GET #index') do
      it('redirects to the user log in') do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #new') do
      it('raises a "No route matches" error') do
        expect do
          get(:new, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('POST #create') do
      it('raises a "No route matches" error') do
        expect do
          post(
            :create,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              ticket: {
                number: 1,
                state: 'reserved',
                ticket_type: 'meal_and_lottery',
              },
            },
          )
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #show') do
      it('redirects to the user log in') do
        get(:show, format: :pdf, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe('GET #edit') do
      it('raises a "No route matches" error') do
        expect do
          get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('PATCH #update') do
      it('raises a "No route matches" error') do
        expect do
          patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { number: 1 } })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('GET #index') do
      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      it('scopes tickets to lottery#printable_tickets') do
        expect_any_instance_of(Lottery).to receive(:printable_tickets).and_return(lottery.printable_tickets)
        get_index
      end

      it('assigns an instance of Lottery to @lottery') do
        get_index
        expect(assigns(:lottery)).to be_an_instance_of(Lottery)
      end

      it('assigns an instance of TicketListing to @ticket_listing') do
        get_index
        expect(assigns(:ticket_listing)).to be_an_instance_of(TicketListing)
      end

      it('returns an http :success status') do
        get_index
        expect(response).to have_http_status(:success)
      end

      it('renders "index"') do
        get_index
        expect(response).to render_template('index')
      end

      it('renders "lotteries/_sidebar"') do
        get_index
        expect(response).to render_template('lotteries/_sidebar')
      end

      it('renders "tickets/ticket_listing_header"') do
        get_index
        expect(response).to render_template('tickets/_ticket_listing_header')
      end

      context('with no tickets to display') do
        it('renders "tickets/_empty_ticket_listing"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('tickets/_empty_ticket_listing')
        end
      end

      context('with no tickets to display when a filter by ticket number was applied') do
        it('renders "tickets/_empty_ticket_listing"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('tickets/_empty_ticket_listing')
        end
      end

      context('with tickets to display') do
        before(:each) do
          create_ticket
        end

        it('renders "tickets/_ticket_listing"') do
          get_index
          expect(response).to render_template('ticket_impressions/_ticket_listing')
        end
      end

      context('with tickets to display when a filter by ticket number was applied') do
        before(:each) do
          create_ticket(number: 99)
        end

        it('renders "tickets/_ticket_listing"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('ticket_impressions/_ticket_listing')
        end
      end

      it('renders "tickets/_ticket_listing" when @ticket_listing#tickets_to_display? is true') do
        expect_any_instance_of(TicketListing).to receive(:tickets_to_display?)
          .at_least(:once)
          .and_return(true)

        get_index
        expect(response).to render_template('ticket_impressions/_ticket_listing')
      end
    end

    describe('GET #new') do
      it('raises a "No route matches" error') do
        expect do
          get(:new, params: { locale: I18n.locale, lottery_id: lottery.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('POST #create') do
      it('raises a "No route matches" error') do
        expect do
          post(
            :create,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              ticket: {
                number: 1,
                state: 'reserved',
                ticket_type: 'meal_and_lottery',
              },
            },
          )
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #show') do
      before(:each) do
        get(:show, format: :pdf, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
      end

      it('returns an http :success status') do
        expect(response).to have_http_status(:success)
      end

      it('returns the content-type to "application/pdf') do
        expect(response.content_type).to eq('application/pdf')
      end
    end

    describe('GET #edit') do
      it('raises a "No route matches" error') do
        expect do
          get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('PATCH #update') do
      it('raises a "No route matches" error') do
        expect do
          patch(
            :update,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              id: ticket.id,
            },
          )
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  private

  def create_ticket(attributes = {})
    Ticket.create!(
      lottery: lottery,
      number: 1,
      guest: guest,
      table: table,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      registered: true,
      dropped_off: false,
      **attributes,
    )
  end
end
