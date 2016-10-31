require 'rails_helper'

RSpec.describe(TablesController, type: :controller) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  describe('GET #index') do
    it('returns all tables') do
      get(:index, params: { lottery_id: lottery.id })
      expect(response).to have_http_status(:success)
      expect(assigns(:tables)).to eq(Table.all)
      expect(response).to render_template(:index)
    end
  end

  describe('GET #new') do
    it('returns a new table') do
      get(:new, params: { lottery_id: lottery.id })
      expect(response).to have_http_status(:success)
      expect(assigns(:table)).to be_a_new(Table)
      expect(response).to render_template(:new)
    end
  end

  describe('POST #create') do
    it('redirects to the table_path when the table was successfully created') do
      expect do
        post(:create, params: { lottery_id: lottery.id, table: { number: 1, capacity: 6 } })
      end.to change { Table.count }.by(1)
      expect(response).to redirect_to(lottery_tables_path(lottery))
    end

    it('renders :new when the table could not be persisted') do
      post(:create, params: { lottery_id: lottery.id, table: { number: nil } })
      expect(response).to have_http_status(:success)
      expect(assigns(:table)).to be_a_new(Table)
      expect(response).to render_template(:new)
    end
  end

  describe('GET #show') do
    it('raises a "No route matches" error') do
      expect do
        get(:show, params: { lottery_id: lottery.id, id: table.id })
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end

  describe('GET #edit') do
    it('returns the requested table') do
      get(:edit, params: { lottery_id: lottery.id, id: table.id })
      expect(response).to have_http_status(:success)
      expect(assigns(:table)).to eq(table)
      expect(response).to render_template(:edit)
    end
  end

  describe('PATCH #update') do
    it('redirects to lottery_tables_path when :number is updated') do
      patch(:update, params: { lottery_id: lottery.id, id: table.id, table: { number: 2 } })
      expect(table.reload.number).to eq(2)
      expect(response).to redirect_to(lottery_tables_path(lottery))
    end

    it('redirects to lottery_tables_path when :capacity is updated') do
      patch(:update, params: { lottery_id: lottery.id, id: table.id, table: { capacity: 8 } })
      expect(table.reload.capacity.to_f).to eq(8)
      expect(response).to redirect_to(lottery_tables_path(lottery))
    end

    it('renders :edit when the table could not be updated') do
      patch(:update, params: { lottery_id: lottery.id, id: table.id, table: { number: nil } })
      expect(response).to have_http_status(:success)
      expect(assigns(:table).number).to be_nil
      expect(table.reload.number).to eq(1)
      expect(response).to render_template(:edit)
    end
  end

  describe('DELETE #destroy') do
    it('raises a "No route matches" error') do
      expect do
        delete(:destroy, params: { lottery_id: lottery.id, id: table.id })
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end
end
