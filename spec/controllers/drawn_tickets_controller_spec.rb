# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(DrawnTicketsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  let(:ticket) do
    create_ticket
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
      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      it('assigns an instance of Lottery to @lottery') do
        get_index
        expect(assigns(:lottery)).to be_an_instance_of(Lottery)
      end

      it('assigns an instance of ResultsListing to @results_listing') do
        get_index
        expect(assigns(:results_listing)).to be_an_instance_of(ResultsListing)
      end

      it('returns an http :success status') do
        get_index
        expect(response).to have_http_status(:success)
      end

      it('renders "index"') do
        get_index
        expect(response).to render_template('index')
      end

      it('renders "lotteries/_sidebar"') do
        get_index
        expect(response).to render_template('lotteries/_sidebar')
      end

      it('renders "drawn_tickets/_listing_header"') do
        get_index
        expect(response).to render_template('drawn_tickets/_listing_header')
      end

      context('with no tickets to display') do
        it('renders "drawn_tickets/_empty_results_listing"') do
          get_index
          expect(response).to render_template('drawn_tickets/_empty_results_listing')
        end
      end

      context('with tickets to display') do
        before(:each) do
          create_ticket
        end

        it('renders "darwn_tickets/_results_listing"') do
          get_index
          expect(response).to render_template('drawn_tickets/_results_listing')
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

  private

  def create_ticket
    lottery.create_ticket(dropped_off: true)
  end
end
