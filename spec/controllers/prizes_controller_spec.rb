require 'rails_helper'

RSpec.describe(PrizesController, type: :controller) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:prize) do
    Prize.create!(
      lottery: lottery,
      draw_order: 1,
      amount: 100.00,
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
      it('redirects to the user log in') do
        get(:new, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('POST #create') do
      it('redirects to the user log in') do
        post(:create, params: { locale: I18n.locale, lottery_id: lottery.id, prize: { draw_order: 1, amount: 100.00} })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id, prize: { draw_order: 2 } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('GET #index') do
      it('returns all prizes ordered by :draw_order') do
        prize_1 = Prize.create!(
          lottery: lottery,
          draw_order: 3,
          amount: 100.00,
        )
        prize_2 = Prize.create!(
          lottery: lottery,
          draw_order: 1,
          amount: 100.00,
        )
        prize_3 = Prize.create!(
          lottery: lottery,
          draw_order: 2,
          amount: 100.00,
        )
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:prizes)).to eq([prize_2, prize_3, prize_1])
        expect(response).to render_template('lotteries/lottery_child_index')
      end
    end

    describe('GET #new') do
      it('returns a new prize') do
        get(:new, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:prize)).to be_a_new(Prize)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the prize_path when the prize was successfully created') do
        expect do
          post(:create, params: { locale: I18n.locale, lottery_id: lottery.id, prize: { draw_order: 1, amount: 100.00} })
        end.to change { Prize.count }.by(1)
        expect(response).to redirect_to(lottery_prizes_path(lottery))
      end

      it('renders :new when the prize could not be persisted') do
        post(:create, params: { locale: I18n.locale, lottery_id: lottery.id, prize: { draw_order: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:prize)).to be_a_new(Prize)
        expect(response).to render_template(:new)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested prize') do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:prize)).to eq(prize)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to lottery_prizes_path when :draw_order is updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id, prize: { draw_order: 2 } })
        expect(prize.reload.draw_order).to eq(2)
        expect(response).to redirect_to(lottery_prizes_path(lottery))
      end

      it('redirects to lottery_prizes_path when :amount is updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id, prize: { amount: 99.99 } })
        expect(prize.reload.amount.to_f).to eq(99.99)
        expect(response).to redirect_to(lottery_prizes_path(lottery))
      end

      it('renders :edit when the prize could not be updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id, prize: { draw_order: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:prize).draw_order).to be_nil
        expect(prize.reload.draw_order).to eq(1)
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, lottery_id: lottery.id, id: prize.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
