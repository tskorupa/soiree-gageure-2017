# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(ResultsController, type: :controller) do
  render_views

  let(:create_lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:create_user) do
    User.create!(
      email: 'abc@def.com',
      password: 'foobar',
    )
  end

  let(:create_prize) do
    lottery = create_lottery
    lottery.prizes.create!(nth_before_last: nil, amount: 1.0, draw_order: 1)
  end

  let(:draw_ticket) do
    lottery = create_lottery
    ticket = lottery.create_ticket
    lottery.draw(ticket: ticket)
  end

  let(:get_index) do
    lottery = create_lottery
    get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
  end

  it('includes LotteryLookup') do
    expect(controller.class.ancestors).to include(LotteryLookup)
  end

  context('When the user is logged out') do
    describe('GET #index') do
      it('redirects to the user log in') do
        get_index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      user = create_user
      sign_in(user)
    end

    describe('GET #index') do
      context('when a non-winning ticket was drawn') do
        before(:each) do
          draw_ticket
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('renders the template "lotteries/_sidebar"') do
          expect(response).to render_template('lotteries/_sidebar')
        end

        it('renders the template "index"') do
          expect(response).to render_template('index')
        end

        it('renders the partial "_index_header"') do
          expect(response).to render_template('_index_header')
        end

        it('renders the partial "_drawn_ticket"') do
          expect(response).to render_template('_drawn_ticket')
        end

        it('renders the partial "_ticket"') do
          expect(response).to render_template('_ticket')
        end

        it('does not render the partial "_prize"') do
          expect(response).not_to render_template('_prize')
        end

        it('renders the partial "_fullscreen"') do
          expect(response).to render_template('_fullscreen')
        end
      end

      context('when a winning ticket was drawn') do
        before(:each) do
          create_prize
          draw_ticket
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('renders the template "lotteries/_sidebar"') do
          expect(response).to render_template('lotteries/_sidebar')
        end

        it('renders the template "index"') do
          expect(response).to render_template('index')
        end

        it('renders the partial "_index_header"') do
          expect(response).to render_template('_index_header')
        end

        it('renders the partial "_drawn_ticket"') do
          expect(response).to render_template('_drawn_ticket')
        end

        it('renders the partial "_ticket"') do
          expect(response).to render_template('_ticket')
        end

        it('renders the partial "_prize"') do
          expect(response).to render_template('_prize')
        end

        it('renders the partial "_fullscreen"') do
          expect(response).to render_template('_fullscreen')
        end
      end

      context('when no ticket was drawn') do
        before(:each) do
          get_index
        end

        it('returns an http :success status') do
          expect(response).to have_http_status(:success)
        end

        it('renders the template "lotteries/_sidebar"') do
          expect(response).to render_template('lotteries/_sidebar')
        end

        it('renders the template "index"') do
          expect(response).to render_template('index')
        end

        it('renders the partial "_index_header"') do
          expect(response).to render_template('_index_header')
        end

        it('renders the partial "_no_drawn_tickets_message"') do
          expect(response).to render_template('_no_drawn_tickets_message')
        end

        it('renders the partial "_fullscreen"') do
          expect(response).to render_template('_fullscreen')
        end
      end
    end
  end
end
