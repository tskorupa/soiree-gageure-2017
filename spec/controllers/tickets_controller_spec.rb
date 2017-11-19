# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
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

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
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
      it('redirects to the user log in') do
        get(:new, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('POST #create') do
      it('redirects to the user log in') do
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
        expect(response).to redirect_to(new_user_session_path)
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
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { number: 1 } })
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

      it('scopes tickets to lottery#tickets') do
        expect_any_instance_of(Lottery).to receive(:tickets).and_return(lottery.tickets)
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

      it('responds an http :success status') do
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

        it('renders "tickets/_table"') do
          get_index
          expect(response).to render_template('tickets/_table')
        end

        it('renders "tickets/_table_row"') do
          get_index
          expect(response).to render_template('tickets/_table_row')
        end
      end

      context('with tickets to display when a filter by ticket number was applied') do
        before(:each) do
          create_ticket(number: 99)
        end

        it('renders "tickets/_table"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('tickets/_table')
        end

        it('renders "tickets/_table_row"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('tickets/_table_row')
        end
      end
    end

    describe('GET #new') do
      it('returns a new ticket') do
        get(:new, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the ticket_path when the ticket was successfully created') do
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
        end.to change { Ticket.count }.by(1)
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('presents the submitted value for :number when the ticket validation fails') do
        post(
          :create,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            ticket: {
              number: -1,
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
        expect(assigns(:ticket).number).to eq(-1)
        expect(response).to render_template(:new)
      end

      it('presents the submitted value for :seller_name when the ticket validation fails') do
        post(
          :create,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            seller_name: 'a',
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
        expect(assigns(:ticket).seller.full_name).to eq('a')
        expect(response).to render_template(:new)
      end

      it('presents the submitted value for :guest_name when the ticket validation fails') do
        post(
          :create,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            guest_name: 'a',
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
        expect(assigns(:ticket).guest.full_name).to eq('a')
        expect(response).to render_template(:new)
      end

      it('presents the submitted value for :sponsor_name when the ticket validation fails') do
        post(
          :create,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            sponsor_name: 'a',
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
        expect(assigns(:ticket).sponsor.full_name).to eq('a')
        expect(response).to render_template(:new)
      end

      it('presents the submitted value for :state when the ticket validation fails') do
        post(
          :create,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            ticket: {
              state: 'a',
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
        expect(assigns(:ticket).state).to eq('a')
        expect(response).to render_template(:new)
      end

      it('presents the submitted value for :ticket_type when the ticket validation fails') do
        post(
          :create,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            ticket: {
              ticket_type: 'a',
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
        expect(assigns(:ticket).ticket_type).to eq('a')
        expect(response).to render_template(:new)
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
      it('returns the requested ticket') do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to eq(ticket)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to lottery_tickets_path when :number is updated') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            ticket: {
              number: 2,
            },
          },
        )
        expect(ticket.reload.number).to eq(2)
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('presents the submitted value for :number when the ticket validation fails') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            ticket: {
              number: -1,
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket).number).to eq(-1)
        expect(response).to render_template(:edit)
      end

      it('redirects to lottery_tickets_path when :seller_name is updated') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            seller_name: 'Clyde',
          },
        )
        expect(ticket.reload.seller.full_name).to eq('Clyde')
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('presents the submitted value for :seller_name when the ticket validation fails') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            seller_name: 'a',
            ticket: {
              number: -1,
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket).seller.full_name).to eq('a')
        expect(response).to render_template(:edit)
      end

      it('redirects to lottery_tickets_path when :guest_name is updated') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: 'Bubbles',
          },
        )
        expect(ticket.reload.guest.full_name).to eq('Bubbles')
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('presents the submitted value for :guest_name when the ticket validation fails') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: 'a',
            ticket: {
              number: -1,
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket).guest.full_name).to eq('a')
        expect(response).to render_template(:edit)
      end

      it('redirects to lottery_tickets_path when :sponsor_name is updated') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            sponsor_name: 'Clyde',
          },
        )
        expect(ticket.reload.sponsor.full_name).to eq('Clyde')
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('presents the submitted value for :sponsor_name when the ticket validation fails') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            sponsor_name: 'a',
            ticket: {
              number: -1,
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket).sponsor.full_name).to eq('a')
        expect(response).to render_template(:edit)
      end

      it('redirects to lottery_tickets_path when :state is updated') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            ticket: {
              state: 'authorized',
            },
          },
        )
        expect(ticket.reload.state).to eq('authorized')
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('presents the submitted value for :state when the ticket validation fails') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            ticket: {
              number: -1,
              state: 'a',
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket).state).to eq('a')
        expect(response).to render_template(:edit)
      end

      it('redirects to lottery_tickets_path when :ticket_type is updated') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            ticket: {
              ticket_type: 'lottery_only',
            },
          },
        )
        expect(ticket.reload.ticket_type).to eq('lottery_only')
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('presents the submitted value for :ticket_type when the ticket validation fails') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            ticket: {
              number: -1,
              ticket_type: 'a',
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket).ticket_type).to eq('a')
        expect(response).to render_template(:edit)
      end

      it('redirects to lottery_tickets_path when :table_number is updated') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            table_number: table.number,
          },
        )
        expect(response).to redirect_to(lottery_tickets_path(lottery))
        expect(ticket.reload.table.number).to eq(table.number)
      end

      it('presents the submitted value for :table_number when the ticket validation fails') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            table_number: -3,
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:builder).table_number).to eq('-3')
        expect(response).to render_template(:edit)
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
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
      **attributes,
    )
  end
end
