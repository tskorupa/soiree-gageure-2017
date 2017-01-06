require 'rails_helper'

RSpec.describe(TicketRegistrationsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
      guest: guest,
    )
  end

  let(:user) do
    User.create!(
      email: 'abc@def.com',
      password: 'foobar',
    )
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
      before(:each) do
        @ticket_1 = Ticket.create!(
          lottery: lottery,
          number: 3,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )
        @ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 1,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
          registered: true,
        )
        @ticket_3 = Ticket.create!(
          lottery: lottery,
          number: 2,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )
      end

      it('returns all unregistered tickets ordered by :number') do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:tickets)).to eq([@ticket_3, @ticket_1])
        expect(response).to render_template('lotteries/lottery_child_index')
      end

      it('returns the ticket with the correct number when params contain :number') do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 2 })
        expect(response).to have_http_status(:success)
        expect(assigns(:tickets)).to eq([@ticket_3])
        expect(response).to render_template('lotteries/lottery_child_index')
      end

      it('returns no ticket when params contain :number of a ticket that is not found') do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 1 })
        expect(response).to have_http_status(:success)
        expect(assigns(:tickets)).to eq([])
        expect(response).to render_template('lotteries/lottery_child_index')
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
      it('returns the requested ticket when the ticket is unregistered') do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to eq(ticket)
        expect(response).to render_template(:edit)
      end

      it('raises a "RecordNotFound" when the requested ticket is registered') do
        ticket.update!(registered: true)
        expect do
          get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe('PATCH #update') do
      it('raises a "RecordNotFound" when the requested ticket is registered') do
        ticket.update!(registered: true)
        expect do
          patch(
            :update,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              id: ticket.id,
              ticket: {
                state: 'paid',
              },
            },
          )
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it('renders the :edit template and sets the ticket#guest = nil when the guest name is empty') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: '',
            ticket: {
              state: 'paid',
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to eq(ticket)
        expect(assigns(:ticket).guest).to be_nil
        expect(response).to render_template(:edit)
      end

      it('renders the :edit template and sets the ticket#guest = nil when the guest name is nil') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: nil,
            ticket: {
              state: 'paid',
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to eq(ticket)
        expect(assigns(:ticket).guest).to be_nil
        expect(response).to render_template(:edit)
      end

      it('renders the :edit template and preserves the submitted value when the ticket_state = :reserved') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: ticket.guest.full_name,
            ticket: {
              state: 'reserved',
            },
          },
        )
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to eq(ticket)
        expect(assigns(:ticket).state).to eq('reserved')
        expect(response).to render_template(:edit)
      end

      it('redirects to the ticket registration path and sets ticket#registered = true when the guest name is present and the ticket#state = :authorized') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: 'FOO',
            ticket: {
              state: 'authorized',
            },
          },
        )
        expect(response).to redirect_to(lottery_ticket_registrations_path(lottery))
        ticket.reload
        expect(ticket.guest.full_name).to eq('Foo')
        expect(ticket.state).to eq('authorized')
        expect(ticket.registered).to be(true)
      end

      it('redirects to the ticket registration path and sets ticket#registered = true when the guest name is present and the ticket#state = :paid') do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: 'FOO',
            ticket: {
              state: 'paid',
            },
          },
        )
        expect(response).to redirect_to(lottery_ticket_registrations_path(lottery))
        ticket.reload
        expect(ticket.guest.full_name).to eq('Foo')
        expect(ticket.state).to eq('paid')
        expect(ticket.registered).to be(true)
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
