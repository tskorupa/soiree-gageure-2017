# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ResultsDashboardsController, type: :controller) do
  include I18nHelper
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
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

    context('#index') do
      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      before(:each) do
        @ticket_1 = Ticket.create!(
          lottery: lottery,
          number: 3,
          state: 'paid',
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
          drawn_position: 2,
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

      context('when a drawn ticket exists and the params are empty') do
        it('returns an http :success status') do
          get_index
          expect(response).to have_http_status(:success)
        end

        it('assigns @draw_results') do
          get_index
          expect(assigns(:draw_results)).to eq([@ticket_4, @ticket_3, nil])
        end

        it('renders the template lotteries/lottery_child_index') do
          get_index
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial results/fullscreen') do
          get_index
          expect(response).to render_template('results/_fullscreen')
        end

        it('renders the partial results_dashboards/index') do
          get_index
          expect(response).to render_template('results_dashboards/_index')
        end

        it('renders the partial results/index_header') do
          get_index
          expect(response).to render_template('results_dashboards/_index_header')
        end

        it('assigns @title when I18n.locale == :en') do
          get_index
          expect(assigns(:title)).to eq('Results dashboard (ordered by drawn position)')
        end

        it('assigns @title when I18n.locale == :fr') do
          with_locale(:fr) do
            get_index
            expect(assigns(:title)).to eq('Tableau des résultats (par ordre de pige)')
          end
        end
      end

      context('when a drawn ticket exists and the params include order_by: "number"') do
        let(:get_index) do
          get(
            :index,
            params: {
              locale: I18n.locale,
              lottery_id: lottery.id,
              order_by: :number,
            },
          )
        end

        it('returns an http :success status') do
          get_index
          expect(response).to have_http_status(:success)
        end

        it('assigns @draw_results') do
          get_index
          expect(assigns(:draw_results)).to eq([nil, @ticket_3, @ticket_4])
        end

        it('renders the template lotteries/lottery_child_index') do
          get_index
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial results/fullscreen') do
          get_index
          expect(response).to render_template('results/_fullscreen')
        end

        it('renders the partial results_dashboards/index') do
          get_index
          expect(response).to render_template('results_dashboards/_index')
        end

        it('renders the partial results/index_header') do
          get_index
          expect(response).to render_template('results_dashboards/_index_header')
        end

        it('assigns @title when I18n.locale == :en') do
          get_index
          expect(assigns(:title)).to eq('Results dashboard (ordered by ticket number)')
        end

        it('assigns @title when I18n.locale == :fr') do
          with_locale(:fr) do
            get_index
            expect(assigns(:title)).to eq('Tableau des résultats (par numéro de billet)')
          end
        end
      end

      context('when no dropped off tickets exist') do
        before(:each) do
          Ticket.update_all(dropped_off: false)
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('does not assign @drawn_results') do
          expect(assigns(:drawn_results)).to be_nil
        end

        it('renders the template lotteries/lottery_child_index') do
          expect(response).to render_template('lotteries/lottery_child_index')
        end

        it('renders the partial results/fullscreen') do
          expect(response).to render_template('results/_fullscreen')
        end

        it('renders the partial results_dashboards/no_tickets_index') do
          expect(response).to render_template('results_dashboards/_no_tickets_index')
        end

        it('renders the partial results/index_header') do
          expect(response).to render_template('results_dashboards/_index_header')
        end

        it('does not assign @title') do
          expect(assigns(:title)).to be_nil
        end
      end
    end
  end
end
