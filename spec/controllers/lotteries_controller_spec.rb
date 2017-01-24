require 'rails_helper'

RSpec.describe(LotteriesController, type: :controller) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:user) do
    User.create!(
      email: 'abc@def.com',
      password: 'foobar',
    )
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
    )
  end

  context('When the user is logged out') do
    describe('GET #index') do
      it('redirects to the user log in') do
        get(:index, params: { locale: I18n.locale })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #new') do
      it('redirects to the user log in') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('POST #create') do
      it('redirects to the user log in') do
        post(:create, params: { locale: I18n.locale, lottery: { event_date: '2016-10-31' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('redirects to the user log in') do
        get(:show, params: { locale: I18n.locale, id: lottery.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, id: lottery.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, id: lottery.id, lottery: { event_date: '2016-01-01' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: lottery.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('GET #index') do
      it('returns all lotteries ordered by event_date: :desc') do
        lottery_1 = Lottery.create!(event_date: Date.yesterday)
        lottery_2 = Lottery.create!(event_date: Date.tomorrow)
        lottery_3 = Lottery.create!(event_date: Date.today)

        get(:index, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:lotteries)).to eq([lottery_2, lottery_3, lottery_1])
        expect(response).to render_template(:index)
      end
    end

    describe('GET #new') do
      it('returns a new lottery') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:lottery)).to be_a_new(Lottery)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the lottery_path when the lottery was successfully created') do
        expect do
          post(:create, params: { locale: I18n.locale, lottery: { event_date: '2016-10-31' } })
        end.to change { Lottery.count }.by(1)
        expect(response).to redirect_to(lotteries_path)
      end

      it('renders :new when the lottery could not be persisted') do
        post(:create, params: { locale: I18n.locale, lottery: { event_date: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:lottery)).to be_a_new(Lottery)
        expect(response).to render_template(:new)
      end
    end

    describe('GET #show') do
      let(:get_show) do
        get(:show, params: { locale: I18n.locale, id: lottery.id })
      end

      context('when the lottery contains 1 unregistered ticket') do
        before(:each) do
          ticket.update!(registered: false)
          get_show
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('assigns @lottery') do
          expect(assigns(:lottery)).to eq(lottery)
        end

        it('assigns @total_num_tickets = 1') do
          expect(assigns(:total_num_tickets)).to eq(1)
        end

        it('assigns @num_unregistered_tickets = 1') do
          expect(assigns(:num_unregistered_tickets)).to eq(1)
        end

        it('assigns @num_tickets_in_circulation = 0') do
          expect(assigns(:num_tickets_in_circulation)).to eq(0)
        end

        it('assigns @num_tickets_in_container = 0') do
          expect(assigns(:num_tickets_in_container)).to eq(0)
        end

        it('assigns @num_drawn_tickets = 0') do
          expect(assigns(:num_drawn_tickets)).to eq(0)
        end
      end

      context('when the lottery contains 1 registered ticket') do
        before(:each) do
          ticket.update!(registered: true)
          get_show
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('assigns @lottery') do
          expect(assigns(:lottery)).to eq(lottery)
        end

        it('assigns @total_num_tickets = 1') do
          expect(assigns(:total_num_tickets)).to eq(1)
        end

        it('assigns @num_unregistered_tickets = 0') do
          expect(assigns(:num_unregistered_tickets)).to eq(0)
        end

        it('assigns @num_tickets_in_circulation = 1') do
          expect(assigns(:num_tickets_in_circulation)).to eq(1)
        end

        it('assigns @num_tickets_in_container = 0') do
          expect(assigns(:num_tickets_in_container)).to eq(0)
        end

        it('assigns @num_drawn_tickets = 0') do
          expect(assigns(:num_drawn_tickets)).to eq(0)
        end
      end

      context('when the lottery contains 1 dropped off ticket') do
        before(:each) do
          ticket.update!(registered: true, dropped_off: true)
          get_show
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('assigns @lottery') do
          expect(assigns(:lottery)).to eq(lottery)
        end

        it('assigns @total_num_tickets = 1') do
          expect(assigns(:total_num_tickets)).to eq(1)
        end

        it('assigns @num_unregistered_tickets = 0') do
          expect(assigns(:num_unregistered_tickets)).to eq(0)
        end

        it('assigns @num_tickets_in_circulation = 0') do
          expect(assigns(:num_tickets_in_circulation)).to eq(0)
        end

        it('assigns @num_tickets_in_container = 1') do
          expect(assigns(:num_tickets_in_container)).to eq(1)
        end

        it('assigns @num_drawn_tickets = 0') do
          expect(assigns(:num_drawn_tickets)).to eq(0)
        end
      end

      context('when the lottery contains 1 drawn ticket') do
        before(:each) do
          ticket.update!(registered: true, dropped_off: true, drawn: true)
          get_show
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('assigns @lottery') do
          expect(assigns(:lottery)).to eq(lottery)
        end

        it('assigns @total_num_tickets = 1') do
          expect(assigns(:total_num_tickets)).to eq(1)
        end

        it('assigns @num_unregistered_tickets = 0') do
          expect(assigns(:num_unregistered_tickets)).to eq(0)
        end

        it('assigns @num_tickets_in_circulation = 0') do
          expect(assigns(:num_tickets_in_circulation)).to eq(0)
        end

        it('assigns @num_tickets_in_container = 0') do
          expect(assigns(:num_tickets_in_container)).to eq(0)
        end

        it('assigns @num_drawn_tickets = 1') do
          expect(assigns(:num_drawn_tickets)).to eq(1)
        end
      end
    end

    describe('GET #edit') do
      it('returns the requested lottery') do
        get(:edit, params: { locale: I18n.locale, id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:lottery)).to eq(lottery)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to lotteries_path when :event_date is updated') do
        new_event_date = 1.month.from_now.to_date
        patch(:update, params: { locale: I18n.locale, id: lottery.id, lottery: { event_date: new_event_date } })
        expect(lottery.reload.event_date).to eq(new_event_date)
        expect(response).to redirect_to(lotteries_path)
      end

      it('redirects to lotteries_path when :meal_voucher_price is updated') do
        new_meal_voucher_price = 125.00
        patch(:update, params: { locale: I18n.locale, id: lottery.id, lottery: { meal_voucher_price: new_meal_voucher_price } })
        expect(lottery.reload.meal_voucher_price).to eq(new_meal_voucher_price)
        expect(response).to redirect_to(lotteries_path)
      end

      it('redirects to lotteries_path when :ticket_price is updated') do
        new_ticket_price = 60.00
        patch(:update, params: { locale: I18n.locale, id: lottery.id, lottery: { ticket_price: new_ticket_price } })
        expect(lottery.reload.ticket_price).to eq(new_ticket_price)
        expect(response).to redirect_to(lotteries_path)
      end

      it('renders :edit when the lottery could not be updated') do
        orginal_event_date = lottery.event_date
        patch(:update, params: { locale: I18n.locale, id: lottery.id, lottery: { event_date: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:lottery).event_date).to be_nil
        expect(lottery.reload.event_date).to eq(orginal_event_date)
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: lottery.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
