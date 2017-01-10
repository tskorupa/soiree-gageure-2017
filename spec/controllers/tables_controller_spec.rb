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
      state: 'reserved',
      ticket_type: 'meal_and_lottery',
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
        post(:create, params: { locale: I18n.locale, lottery_id: lottery.id, table: { number: 1, capacity: 6 } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('redirects to the user log in') do
        get(:show, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id, table: { number: 2 } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  context('When a user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('GET #index') do
      it('returns all tables ordered by :number') do
        table_1 = Table.create!(
          lottery: lottery,
          number: 3,
          capacity: 6,
        )
        table_2 = Table.create!(
          lottery: lottery,
          number: 1,
          capacity: 6,
        )
        table_3 = Table.create!(
          lottery: lottery,
          number: 2,
          capacity: 6,
        )

        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:tables)).to eq([table_2, table_3, table_1])
        expect(response).to render_template('lotteries/lottery_child_index')
      end
    end

    describe('GET #new') do
      it('returns a new table') do
        get(:new, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:table)).to be_a_new(Table)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the table_path when the table was successfully created') do
        expect do
          post(:create, params: { locale: I18n.locale, lottery_id: lottery.id, table: { number: 1, capacity: 6 } })
        end.to change { Table.count }.by(1)
        expect(response).to redirect_to(lottery_tables_path(lottery))
      end

      it('renders :new when the table could not be persisted') do
        post(:create, params: { locale: I18n.locale, lottery_id: lottery.id, table: { number: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:table)).to be_a_new(Table)
        expect(response).to render_template(:new)
      end
    end

    describe('GET #show') do
      before(:each) do
        ticket.update!(table: table)
        get(:show, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id })
      end

      it('returns :success') do
        expect(response).to have_http_status(:success)
      end

      it('renders :show') do
        expect(response).to render_template(:show)
      end

      it('assigns @table') do
        expect(assigns(:table)).to eq(table)
      end

      it('assigns @tickets') do
        expect(assigns(:tickets)).to eq([ticket])
      end
    end

    describe('GET #edit') do
      it('returns the requested table') do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:table)).to eq(table)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to lottery_tables_path when :number is updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id, table: { number: 2 } })
        expect(table.reload.number).to eq(2)
        expect(response).to redirect_to(lottery_tables_path(lottery))
      end

      it('redirects to lottery_tables_path when :capacity is updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id, table: { capacity: 8 } })
        expect(table.reload.capacity.to_f).to eq(8)
        expect(response).to redirect_to(lottery_tables_path(lottery))
      end

      it('renders :edit when the table could not be updated') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id, table: { number: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:table).number).to be_nil
        expect(table.reload.number).to eq(1)
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, lottery_id: lottery.id, id: table.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
