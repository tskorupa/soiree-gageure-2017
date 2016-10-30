require 'rails_helper'

RSpec.describe(LotteriesController, type: :controller) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  describe('GET #index') do
    it('returns all lotteries') do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:lotteries)).to eq(Lottery.all)
      expect(response).to render_template(:index)
    end
  end

  describe('GET #new') do
    it('returns a new lottery') do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:lottery)).to be_a_new(Lottery)
      expect(response).to render_template(:new)
    end
  end

  describe('POST #create') do
    it('redirects to the lottery_path when the lottery was successfully created') do
      expect do
        post(:create, lottery: { event_date: '2016-10-31' })
      end.to change { Lottery.count }.by(1)
      expect(response).to redirect_to(lotteries_path)
    end

    it('renders :new when the lottery could not be persisted') do
      post(:create, lottery: { event_date: nil })
      expect(response).to have_http_status(:success)
      expect(assigns(:lottery)).to be_a_new(Lottery)
      expect(response).to render_template(:new)
    end
  end

  describe('GET #show') do
    it('raises a "No route matches" error') do
      expect do
        get(:show, id: lottery.id)
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end

  describe('GET #edit') do
    it('returns the requested lottery') do
      get(:edit, id: lottery.id)
      expect(response).to have_http_status(:success)
      expect(assigns(:lottery)).to eq(lottery)
      expect(response).to render_template(:edit)
    end
  end

  describe('PATCH #update') do
    it('redirects to lotteries_path when :event_date is updated') do
      new_event_date = 1.month.from_now.to_date
      patch(:update, id: lottery.id, lottery: { event_date: new_event_date })
      expect(lottery.reload.event_date).to eq(new_event_date)
      expect(response).to redirect_to(lotteries_path)
    end

    it('redirects to lotteries_path when :meal_voucher_price is updated') do
      new_meal_voucher_price = 125.00
      patch(:update, id: lottery.id, lottery: { meal_voucher_price: new_meal_voucher_price })
      expect(lottery.reload.meal_voucher_price).to eq(new_meal_voucher_price)
      expect(response).to redirect_to(lotteries_path)
    end

    it('redirects to lotteries_path when :ticket_price is updated') do
      new_ticket_price = 60.00
      patch(:update, id: lottery.id, lottery: { ticket_price: new_ticket_price })
      expect(lottery.reload.ticket_price).to eq(new_ticket_price)
      expect(response).to redirect_to(lotteries_path)
    end

    it('renders :edit when the lottery could not be updated') do
      orginal_event_date = lottery.event_date
      patch(:update, id: lottery.id, lottery: { event_date: nil })
      expect(response).to have_http_status(:success)
      expect(assigns(:lottery).event_date).to be_nil
      expect(lottery.reload.event_date).to eq(orginal_event_date)
      expect(response).to render_template(:edit)
    end
  end

  describe('DELETE #destroy') do
    it('raises a "No route matches" error') do
      expect do
        delete(:destroy, id: lottery.id)
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end
end
