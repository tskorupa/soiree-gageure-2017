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

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id })
        expect(response).to redirect_to(new_user_session_path)
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

    describe('PATCH #update') do
      let(:patch_update) do
        patch(
          :update,
          params: {
            locale: I18n.locale,
            lottery_id: lottery.id,
            id: ticket.id,
          },
        )
      end

      context('when lottery#locked? returns false') do
        before(:each) do
          expect_any_instance_of(Lottery).to receive(:locked?).and_return(false)
          patch_update
        end

        it('returns http :no_content status') do
          expect(response).to have_http_status(:no_content)
        end

        it('contains no body') do
          expect(response.body).to be_empty
        end
      end

      context('when lottery#locked? returns true') do
        before(:each) do
          expect_any_instance_of(Lottery).to receive(:locked?).and_return(true)
        end

        it('raises an exception when the ticket is not included in lottery#drawable_tickets') do
          expect_any_instance_of(Lottery).to receive(:drawable_tickets).and_return(Ticket.none)
          expect { patch_update }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it('delegates to lottery#draw') do
          expect_any_instance_of(Lottery).to receive(:drawable_tickets).and_return(Ticket.where(id: ticket.id))
          expect_any_instance_of(Lottery).to receive(:draw).with(ticket: ticket)
          patch_update
        end

        it('redirects to the lottery_ticket_draws_path') do
          expect_any_instance_of(Lottery).to receive(:drawable_tickets).and_return(Ticket.where(id: ticket.id))
          patch_update
          expect(response).to redirect_to(lottery_ticket_draws_path(lottery))
        end
      end
    end
  end
end
