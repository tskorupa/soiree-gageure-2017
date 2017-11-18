# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketDropOffsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
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
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
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
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        expect(response).to redirect_to(new_user_session_path)
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

      it('scopes tickets to lottery#droppable_tickets') do
        expect_any_instance_of(Lottery).to receive(:droppable_tickets).and_return(lottery.droppable_tickets)
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
          expect(response).to render_template('ticket_drop_offs/_ticket_listing')
        end
      end

      context('with tickets to display when a filter by ticket number was applied') do
        before(:each) do
          create_ticket(number: 99)
        end

        it('renders "tickets/_ticket_listing"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('ticket_drop_offs/_ticket_listing')
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
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
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
      let(:patch_update) do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
          },
        )
      end

      context('when lottery#locked == true') do
        before(:each) do
          lottery.update!(locked: true)
          patch_update
        end

        it('returns http :no_content status') do
          expect(response).to have_http_status(:no_content)
        end

        it('has an empty body') do
          expect(response.body).to be_empty
        end
      end

      context('when ticket#dropped_off = true') do
        it('raises a "RecordNotFound"') do
          ticket.update!(dropped_off: true)
          expect { patch_update }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context('when ticket#dropped_off = false') do
        it('redirects to the lottery_ticket_drop_offs_path') do
          patch_update
          expect(response).to redirect_to(lottery_ticket_drop_offs_path(lottery))
        end

        it('sets ticket#dropped_off = true when ticket is dropped off after registration') do
          expect { patch_update }.to change { ticket.reload.dropped_off }.from(false).to(true)
        end
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
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      registered: true,
      dropped_off: false,
      **attributes,
    )
  end
end
