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
    Ticket.create!(
      lottery: lottery,
      number: 1,
      guest: guest,
      table: table,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      registered: true,
      dropped_off: false,
    )
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
      before(:each) do
        @ticket_1 = Ticket.create!(
          lottery: lottery,
          number: 3,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
          registered: false,
          dropped_off: false,
        )
        @ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 1,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          registered: true,
          dropped_off: false,
        )
        @ticket_3 = Ticket.create!(
          lottery: lottery,
          number: 2,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          registered: true,
          dropped_off: true,
        )
        @ticket_4 = Ticket.create!(
          lottery: lottery,
          number: 4,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          registered: true,
          dropped_off: false,
        )
      end

      context('when not specifying :number in the params') do
        before(:each) do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns all tickets that are registered and are of type meal_and_lottery ordered by :number') do
          expect(assigns(:tickets)).to eq([@ticket_2, @ticket_3, @ticket_4])
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the template ticket_impressions/index') do
          expect(response).to render_template('ticket_impressions/_index')
        end
      end

      context('when specyfying the :number of a registered but not dropped off ticket in the params') do
        before(:each) do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 4 })
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns the ticket#number = params[:number]') do
          expect(assigns(:tickets)).to eq([@ticket_4])
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the template ticket_impressions/index') do
          expect(response).to render_template('ticket_impressions/_index')
        end
      end

      context('when specyfying the :number of a ticket that is not printable') do
        before(:each) do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 3 })
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns the ticket#number = params[:number]') do
          expect(assigns(:tickets)).to be_empty
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the template ticket_impressions/index') do
          expect(response).to render_template('ticket_impressions/_index')
        end
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
end
