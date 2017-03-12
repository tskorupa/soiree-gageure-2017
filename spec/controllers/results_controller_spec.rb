require 'rails_helper'

RSpec.describe(ResultsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Date.today)
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
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          drawn_position: nil,
        )
        @ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 1,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          registered: true,
          drawn_position: nil,
        )
        @ticket_3 = Ticket.create!(
          lottery: lottery,
          number: 2,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          drawn_position: 13,
        )
        @ticket_4 = Ticket.create!(
          lottery: lottery,
          number: 4,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          drawn_position: 23
        )
      end

      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      context('when a drawn ticket exists') do
        before(:each) do
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns the last drawn ticket') do
          expect(assigns(:ticket)).to eq(@ticket_4)
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial results/index_header') do
          expect(response).to render_template('results/_index_header')
        end

        it('renders the partial results/fullscreen') do
          expect(response).to render_template('results/_fullscreen')
        end

        it('renders the partial results/index') do
          expect(response).to render_template('results/_index')
        end
      end

      context('when no drawn ticket exists') do
        before(:each) do
          Ticket.update_all(drawn_position: nil)
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('does not assign @ticket') do
          expect(assigns(:ticket)).to be_nil
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial results/index_header') do
          expect(response).to render_template('results/_index_header')
        end

        it('renders the partial results/fullscreen') do
          expect(response).to render_template('results/_fullscreen')
        end

        it('renders the partial results/empty_index') do
          expect(response).to render_template('results/_empty_index')
        end
      end
    end
  end
end
