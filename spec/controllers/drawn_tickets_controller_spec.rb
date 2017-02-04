require 'rails_helper'

RSpec.describe(DrawnTicketsController, type: :controller) do
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
      drawn: true,
      drawn_at: Time.now.utc,
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
          number: 1,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
          drawn: false,
        )
        @ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 2,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          drawn: false,
        )
        @ticket_3 = Ticket.create!(
          lottery: lottery,
          number: 3,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn: true,
          drawn_at: Time.now.utc,
        )
        @ticket_4 = Ticket.create!(
          lottery: lottery,
          number: 4,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn: true,
          drawn_at: 5.minutes.ago.utc,
        )
      end

      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      context('when all tickets for the given lottery have ticket#dropped_off == false') do
        before(:each) do
          Ticket.update_all(dropped_off: false)
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial drawn_tickets/no_tickets_index') do
          expect(response).to render_template('drawn_tickets/_no_tickets_index')
        end
      end

      context('when some tickets have ticket#dropped_off == true and all tickets are ticket#drawn == false') do
        before(:each) do
          Ticket.update_all(drawn: false)
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns a draw position for each dropped off ticket and sets the drawn ticket to nil') do
          expect(assigns(:draw_positions)).to eq([[1, nil],[2, nil]])
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial drawn_tickets/index') do
          expect(response).to render_template('drawn_tickets/_index')
        end
      end

      context('when some tickets have ticket#dropped_off == true and some tickets are ticket#drawn == true') do
        before(:each) do
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns a draw position for each dropped off ticket and sets the drawn ticket') do
          expect(assigns(:draw_positions)).to eq([[1, @ticket_4],[2, @ticket_3]])
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial drawn_tickets/index') do
          expect(response).to render_template('drawn_tickets/_index')
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
      it('raises a "RecordNotFound" when ticket#drawn = false') do
        ticket.update!(drawn: false)
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

      context('when ticket#drawn = true') do
        let(:update) do
          patch(
            :update,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              id: ticket.id,
            },
          )
        end

        it('redirects to the lottery_drawn_tickets_path') do
          update
          expect(response).to redirect_to(lottery_drawn_tickets_path(lottery))
        end

        it('sets ticket#drawn = false') do
          expect { update }.to change { ticket.reload.drawn }.from(true).to(false)
        end

        it('sets ticket#drawn_at = nil') do
          expect(ticket.drawn_at).not_to be_nil
          expect { update }.to change { ticket.reload.drawn_at }.to(nil)
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
