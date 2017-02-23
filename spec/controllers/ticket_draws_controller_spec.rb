require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe(TicketDrawsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      dropped_off: true,
      drawn_position: 13,
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
          number: 3,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
          dropped_off: false,
          drawn_position: nil,
        )
        @ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 1,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn_position: nil,
        )
        @ticket_3 = Ticket.create!(
          lottery: lottery,
          number: 2,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn_position: nil,
        )
        @ticket_4 = Ticket.create!(
          lottery: lottery,
          number: 4,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn_position: 1,
        )
      end

      context('when not specifying :number in the params') do
        before(:each) do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns all dropped off and not drawn tickets when :number is not specified in the params') do
          expect(assigns(:tickets)).to eq([@ticket_2, @ticket_3])
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
      before(:each) do
        ticket.update!(
          dropped_off: true,
          drawn_position: nil,
        )
      end

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

      context('when lottery#locked == false') do
        it('returns http :no_content status') do
          update
          expect(response).to have_http_status(:no_content)
        end

        it('contains no body') do
          update
          expect(response.body).to be_empty
        end
      end

      context('when lottery#locked == true') do
        before(:each) do
          lottery.update!(locked: true)
        end

        it('raises a "RecordNotFound" when ticket#dropped_off is false') do
          ticket.update!(dropped_off: false)
          expect { update }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it('raises a "RecordNotFound" when ticket#drawn_position is set') do
          ticket.update!(drawn_position: 13)
          expect { update }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it('redirects to the lottery_ticket_draws_path') do
          update
          expect(response).to redirect_to(lottery_ticket_draws_path(lottery))
        end

        it('sets ticket#drawn_position') do
          expect { update }.to change { ticket.reload.drawn_position }.from(nil).to(1)
        end

        it('sets ticket#prize') do
          prize = Prize.create!(
            lottery: lottery,
            draw_order: 1,
            nth_before_last: nil,
            amount: 1.00,
          )
          expect { update }.to change { ticket.reload.prize }.from(nil).to(prize)
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
