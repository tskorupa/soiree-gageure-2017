require 'rails_helper'

RSpec.describe(TicketRegistrationsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  let(:ticket) do
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      guest: guest,
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
      it('raises an exception') do
        expect do
          get(:new, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('POST #create') do
      it('raises an exception') do
        expect do
          post(
            :create,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              ticket: {
                number: 1,
                ticket_type: 'meal_and_lottery',
              },
            },
          )
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #show') do
      it('raises an exception') do
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
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { number: 1 } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises an exception') do
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
      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      it('assigns @number with the value of params[:number]') do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 1 })
        expect(assigns(:number)).to eq('1')
      end

      it('assigns @tickets with empty when no ticket#registered == false exist') do
        ticket.update!(registered: true)
        get_index
        expect(assigns(:tickets)).to eq(Ticket.none)
      end

      it('assigns @tickets with empty when ticket#state == "reserved" exist') do
        ticket.update!(state: 'reserved')
        get_index
        expect(assigns(:tickets)).to eq(Ticket.none)
      end

      it('assigns @tickets with non-empty when ticket#state == "paid" exist') do
        ticket.update!(state: 'paid')
        get_index
        expect(assigns(:tickets)).to eq([ticket])
      end

      it('assigns @tickets with non-empty when ticket#state == "authorized" exist') do
        ticket.update!(state: 'authorized')
        get_index
        expect(assigns(:tickets)).to eq([ticket])
      end

      it('orders @tickets by ticket#number') do
        ticket_1 = Ticket.create!(
          lottery: lottery,
          number: 9,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
        )
        ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 3,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
        )
        get_index
        expect(assigns(:tickets)).to eq([ticket_2, ticket_1])
      end

      it('scopes @tickets to ticket#number == params[:number]') do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: ticket.number })
        expect(assigns(:tickets)).to eq([ticket])

        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number: 2 })
        expect(assigns(:tickets)).to eq(Ticket.none)
      end

      it('returns an http :success status') do
        get_index
        expect(response).to have_http_status(:success)
      end

      it('renders lotteries/lottery_child_index') do
        get_index
        expect(response).to render_template('lotteries/lottery_child_index')
      end

      it('renders ticket_registrations/index') do
        get_index
        expect(response).to render_template('ticket_registrations/_index')
      end
    end

    describe('GET #new') do
      it('raises an exception') do
        expect do
          get(:new, params: { locale: I18n.locale, lottery_id: lottery.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('POST #create') do
      it('raises an exception') do
        expect do
          post(:create, params: { locale: I18n.locale, lottery_id: lottery.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #show') do
      it('raises an exception') do
        expect do
          get(:show, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      let(:get_edit) do
        get(:edit, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
      end

      context('when lottery#locked == true') do
        before(:each) do
          lottery.update!(locked: true)
          get_edit
        end

        it('returns http :no_content status') do
          expect(response).to have_http_status(:no_content)
        end

        it('has an empty body') do
          expect(response.body).to be_empty
        end
      end

      context('when lottery#locked == false') do
        it('returns http :success') do
          get_edit
          expect(response).to have_http_status(:success)
        end

        it('assigns @ticket') do
          get_edit
          expect(assigns(:ticket)).to eq(ticket)
        end

        it('renders the :edit template') do
          get_edit
          expect(response).to render_template(:edit)
        end

        it('raises an exception when ticket#registered == true') do
          ticket.update!(registered: true)
          expect { get_edit }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it('raises an exception when ticket#state == "reserved"') do
          ticket.update!(state: 'reserved')
          expect { get_edit }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe('PATCH #update') do
      let(:patch_update) do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
            guest_name: 'FOO',
            table_number: table.number,
            ticket: {
              ticket_type: 'lottery_only',
            },
          },
        )
      end

      context('when lottery#locked == true') do
        before(:each) do
          lottery.update!(locked: true)
          patch_update
        end

        it('returns http :no_content status') do
          expect(response).to have_http_status(:no_content)
        end

        it('has an empty body') do
          expect(response.body).to be_empty
        end
      end

      it('raises an exception when ticket#registered == true') do
        ticket.update!(registered: true)
        expect { patch_update }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it('raises an exception when ticket#state == "reserved"') do
        ticket.update!(state: 'reserved')
        expect { patch_update }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context('when the validation fails') do
        before(:each) do
          patch(
            :update,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              id: ticket.id,
              guest_name: '',
              table_number: -1,
              ticket: {
                ticket_type: 'does not exist',
              },
            },
          )
        end

        it('responds with http status :success') do
          expect(response).to have_http_status(:success)
        end

        it('renders the :edit tamplate') do
          expect(response).to render_template(:edit)
        end

        it('assigns ticket#guest to nil when ticket#guest_name is an empty string') do
          expect(assigns(:ticket).guest).to be_nil
        end

        it('preserves the submitted value for :table_number') do
          expect(assigns(:builder).table_number).to eq('-1')
        end

        it('preserves the submitted value for ticket#ticket_type') do
          expect(assigns(:ticket).ticket_type).to eq('does not exist')
        end

        it('does not change ticket#registered when the update fails') do
          expect(assigns(:ticket).registered).to be(false)
        end
      end

      context('when the update succeeds') do
        it('redirects to the ticket registration path') do
          patch_update
          expect(response).to redirect_to(lottery_ticket_registrations_path(lottery))
        end

        it('permits to change the guest name') do
          expect { patch_update }.to change { ticket.reload.guest.full_name }.from('Bubbles').to('Foo')
        end

        it('permits to change ticket#table when specifying :table_number') do
          expect { patch_update }
            .to change { ticket.reload.table_id }
            .from(nil).to(table.id)
        end

        it('permits to change ticket#ticket_type') do
          expect { patch_update }.to change { ticket.reload.ticket_type }.from('meal_and_lottery').to('lottery_only')
        end

        it('sets ticket#registered to true') do
          expect { patch_update }.to change { ticket.reload.registered }.from(false).to(true)
        end
      end
    end

    describe('DELETE #destroy') do
      it('raises an exception') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
