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

  describe('GET #index') do
    it('returns all prizes') do
      get(:index, params: { lottery_id: lottery.id })
      expect(response).to have_http_status(:success)
      expect(assigns(:prizes)).to eq(Prize.all)
      expect(response).to render_template('lotteries/lottery_child_index')
    end
  end

  describe('GET #new') do
    it('returns a new prize') do
      get(:new, params: { lottery_id: lottery.id })
      expect(response).to have_http_status(:success)
      expect(assigns(:prize)).to be_a_new(Prize)
      expect(response).to render_template(:new)
    end
  end

  describe('POST #create') do
    it('redirects to the prize_path when the prize was successfully created') do
      expect do
        post(:create, params: { lottery_id: lottery.id, prize: { draw_order: 1, amount: 100.00} })
      end.to change { Prize.count }.by(1)
      expect(response).to redirect_to(lottery_prizes_path(lottery))
    end

    it('renders :new when the prize could not be persisted') do
      post(:create, params: { lottery_id: lottery.id, prize: { draw_order: nil } })
      expect(response).to have_http_status(:success)
      expect(assigns(:prize)).to be_a_new(Prize)
      expect(response).to render_template(:new)
    end
  end

  describe('GET #show') do
    it('raises a "No route matches" error') do
      expect do
        get(:show, params: { lottery_id: lottery.id, id: prize.id })
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end

  describe('GET #edit') do
    it('returns the requested prize') do
      get(:edit, params: { lottery_id: lottery.id, id: prize.id })
      expect(response).to have_http_status(:success)
      expect(assigns(:prize)).to eq(prize)
      expect(response).to render_template(:edit)
    end
  end

  describe('PATCH #update') do
    it('redirects to lottery_prizes_path when :draw_order is updated') do
      patch(:update, params: { lottery_id: lottery.id, id: prize.id, prize: { draw_order: 2 } })
      expect(prize.reload.draw_order).to eq(2)
      expect(response).to redirect_to(lottery_prizes_path(lottery))
    end

    it('redirects to lottery_prizes_path when :amount is updated') do
      patch(:update, params: { lottery_id: lottery.id, id: prize.id, prize: { amount: 99.99 } })
      expect(prize.reload.amount.to_f).to eq(99.99)
      expect(response).to redirect_to(lottery_prizes_path(lottery))
    end

    it('renders :edit when the prize could not be updated') do
      patch(:update, params: { lottery_id: lottery.id, id: prize.id, prize: { draw_order: nil } })
      expect(response).to have_http_status(:success)
      expect(assigns(:prize).draw_order).to be_nil
      expect(prize.reload.draw_order).to eq(1)
      expect(response).to render_template(:edit)
    end
  end

  describe('DELETE #destroy') do
    it('raises a "No route matches" error') do
      expect do
        delete(:destroy, params: { lottery_id: lottery.id, id: prize.id })
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end
end
