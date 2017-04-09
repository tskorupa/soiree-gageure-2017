require 'rails_helper'

RSpec.describe(DrawnTicketsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:ticket) do
    lottery.create_ticket(dropped_off: true)
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
        patch(:update, params: { locale: I18n.locale, lottery_id: lottery.id, id: ticket.id, ticket: { number: 1 } })
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
          number: 1,
          state: 'reserved',
          ticket_type: 'meal_and_lottery',
          dropped_off: false,
          drawn_position: nil,
        )
        @ticket_2 = Ticket.create!(
          lottery: lottery,
          number: 2,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn_position: nil,
        )
        @ticket_3 = Ticket.create!(
          lottery: lottery,
          number: 3,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn_position: 2,
        )
        @ticket_4 = Ticket.create!(
          lottery: lottery,
          number: 4,
          guest: guest,
          state: 'paid',
          ticket_type: 'meal_and_lottery',
          dropped_off: true,
          drawn_position: 1,
        )
      end

      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      context('when all tickets for the given lottery have ticket#dropped_off == false') do
        before(:each) do
          Ticket.update_all(dropped_off: false)
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial drawn_tickets/no_tickets_index') do
          expect(response).to render_template('drawn_tickets/_no_tickets_index')
        end
      end

      context('when some tickets have ticket#dropped_off == true and all tickets are ticket#drawn_position == nil') do
        before(:each) do
          Ticket.update_all(drawn_position: nil)
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns a draw position for each dropped off ticket along with nil as ticket placeholders') do
          expect(assigns(:draw_results)).to eq([[1, nil], [2, nil], [3, nil]])
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial drawn_tickets/index') do
          expect(response).to render_template('drawn_tickets/_index')
        end
      end

      context('when some tickets have ticket#dropped_off == true and some tickets have ticket#drawn_position set and a prize exists for the first drawn ticket') do
        before(:each) do
          lottery.prizes.create!(draw_order: 1, nth_before_last: nil, amount: 3.00)
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('returns a draw position for each dropped off ticket and sets the drawn ticket') do
          expect(assigns(:draw_results)).to eq([[1, @ticket_4, 3.0],[2, @ticket_3], [3, nil]])
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial drawn_tickets/index') do
          expect(response).to render_template('drawn_tickets/_index')
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

      before(:each) do
        lottery.draw(ticket: ticket)
      end

      it('returns the last drawn ticket into the draw') do
        expect(lottery.drawable_tickets).not_to include(ticket)
        expect(lottery.drawn_tickets).to include(ticket)

        patch_update

        expect(lottery.drawable_tickets).to include(ticket)
        expect(lottery.drawn_tickets).not_to include(ticket)
      end

      it('redirects to the lottery_drawn_tickets_path') do
        patch_update
        expect(response).to redirect_to(lottery_drawn_tickets_path(lottery))
      end
    end
  end
end
