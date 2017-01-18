require 'rails_helper'

RSpec.describe(TicketDrawsController, type: :controller) do
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
      guest: guest,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      registered: true,
      dropped_off: true,
      drawn: false,
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
      it('raises a "No route matches" error') do
        expect do
          get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
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
          registered: false,
          dropped_off: false,
          drawn: false,
        )
        @ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 1,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          registered: true,
          dropped_off: false,
          drawn: false,
        )
        @ticket_3 = Ticket.create!(
          lottery: lottery,
          number: 2,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          registered: true,
          dropped_off: true,
          drawn: false,
        )
        @ticket_4 = Ticket.create!(
          lottery: lottery,
          number: 4,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          registered: true,
          dropped_off: true,
          drawn: true,
        )
      end

      context('when not specifying :number in the params') do
        before(:each) do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns no tickets when :number is not specified in the params') do
          expect(assigns(:tickets)).to be_empty
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial ticket_draws/index') do
          expect(response).to render_template('ticket_draws/_index')
        end
      end

      context('when specyfying the :number of a dropped off but not drawn ticket in the params') do
        before(:each) do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 2 })
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns the ticket#number = params[:number]') do
          expect(assigns(:tickets)).to eq([@ticket_3])
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial ticket_draws/index') do
          expect(response).to render_template('ticket_draws/_index')
        end
      end

      context('when specyfying the :number a drawn ticket in the params') do
        before(:each) do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 4 })
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

        it('renders the partial ticket_draws/index') do
          expect(response).to render_template('ticket_draws/_index')
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
      it('raises a "RecordNotFound" when the requested ticket is drawn') do
        ticket.update!(drawn: true)
        expect do
          patch(
            :update,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              id: ticket.id,
            },
          )
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      context('when the ticket#registered = true and ticket#dropped_off = true and ticket#drawn = false') do
        before(:each) do
          patch(
            :update,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              id: ticket.id,
            },
          )
        end

        it('redirects to the lottery_ticket_draws_path') do
          expect(response).to redirect_to(lottery_ticket_draws_path(lottery))
        end

        it('sets ticket#drawn = true when ticket is drawn during the lottery') do
          expect(ticket.reload.drawn).to be(true)
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
end
