require 'rails_helper'

RSpec.describe(TicketsController, type: :controller) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      seller: seller,
      number: 1,
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
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
              seller_id: seller.id,
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
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { seller_id: seller.id } })
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
      it('returns all tickets ordered by :number') do
        ticket_1 = Ticket.create!(
          lottery: lottery,
          seller: seller,
          number: 3,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )
        ticket_2 = Ticket.create!(
          lottery: lottery,
          seller: seller,
          number: 1,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )
        ticket_3 = Ticket.create!(
          lottery: lottery,
          seller: seller,
          number: 2,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
        )

        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:tickets)).to eq([ticket_2, ticket_3, ticket_1])
        expect(response).to render_template('lotteries/lottery_child_index')
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
                seller_id: seller.id,
                number: 1,
                state: 'reserved',
                ticket_type: 'meal_and_lottery',
              },
            },
          )
        end.to change { Ticket.count }.by(1)
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('renders :new when the ticket could not be persisted') do
        post(:create, params: { locale: I18n.locale, lottery_id: lottery.id, ticket: { seller_id: seller.id, number: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket)).to be_a_new(Ticket)
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
      it('redirects to lottery_tickets_path when :seller_id is updated') do
        other_seller = Seller.create!(full_name: 'Clyde')
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { seller_id: other_seller.id } })
        expect(ticket.reload.seller).to eq(other_seller)
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('redirects to lottery_tickets_path when :guest_id is updated') do
        guest = Guest.create!(full_name: 'Bubbles')
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { guest_id: guest.id } })
        expect(ticket.reload.guest).to eq(guest)
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('redirects to lottery_tickets_path when :sponsor_id is updated') do
        sponsor = Sponsor.create!(full_name: 'Clyde')
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { sponsor_id: sponsor.id } })
        expect(ticket.reload.sponsor).to eq(sponsor)
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('redirects to lottery_tickets_path when :number is updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { number: 2 } })
        expect(ticket.reload.number).to eq(2)
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('redirects to lottery_tickets_path when :state is updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { state: 'authorized' } })
        expect(ticket.reload.state).to eq('authorized')
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('redirects to lottery_tickets_path when :ticket_type is updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { ticket_type: 'lottery_only' } })
        expect(ticket.reload.ticket_type).to eq('lottery_only')
        expect(response).to redirect_to(lottery_tickets_path(lottery))
      end

      it('renders :edit when the ticket could not be updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { number: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:ticket).number).to be_nil
        expect(ticket.reload.number).to eq(1)
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
end
