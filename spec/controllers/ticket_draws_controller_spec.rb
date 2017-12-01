# frozen_string_literal: true
require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe(TicketDrawsController, type: :controller) do
  render_views

  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
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
      let(:get_index) do
        get(:index, params: { locale: I18n.locale, lottery_id: lottery.id })
      end

      it('scopes tickets to lottery#drawable_tickets') do
        expect_any_instance_of(Lottery).to receive(:drawable_tickets).and_return(lottery.drawable_tickets)
        get_index
      end

      it('assigns an instance of Lottery to @lottery') do
        get_index
        expect(assigns(:lottery)).to be_an_instance_of(Lottery)
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

      it('renders "tickets/_ticket_listing_header"') do
        get_index
        expect(response).to render_template('tickets/_ticket_listing_header')
      end

      context('with no tickets to display') do
        it('renders "tickets/_empty_ticket_listing"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('tickets/_empty_ticket_listing')
        end
      end

      context('with no tickets to display when a filter by ticket number was applied') do
        it('renders "tickets/_empty_ticket_listing"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('tickets/_empty_ticket_listing')
        end
      end

      context('with tickets to display') do
        before(:each) do
          create_ticket
        end

        it('renders "tickets/_ticket_listing"') do
          get_index
          expect(response).to render_template('ticket_draws/_ticket_listing')
        end

        it('renders "results/_prize" when the next drawn ticket merits a prize') do
          Prize.create!(lottery: lottery, draw_order: 2, amount: 1)
          get_index
          expect(response).to render_template('results/_prize')
        end

        it('does not render "results/_prize" when the next drawn ticket merits no prize') do
          get_index
          expect(response).not_to render_template('results/_prize')
        end
      end

      context('with tickets to display when a filter by ticket number was applied') do
        before(:each) do
          create_ticket(number: 99)
        end

        it('renders "tickets/_ticket_listing"') do
          get(:index, params: { locale: I18n.locale, lottery_id: lottery.id, number_filter: '99' })
          expect(response).to render_template('ticket_draws/_ticket_listing')
        end

        it('renders "results/prize" when the next drawn ticket merits a prize') do
          Prize.create!(lottery: lottery, draw_order: 2, amount: 1)
          get_index
          expect(response).to render_template('results/_prize')
        end

        it('does not render "results/prize" when the next drawn ticket merits no prize') do
          get_index
          expect(response).not_to render_template('results/_prize')
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

  private

  def create_ticket(attributes = {})
    Ticket.create!(
      lottery: lottery,
      number: 1,
      state: 'paid',
      ticket_type: 'meal_and_lottery',
      dropped_off: true,
      drawn_position: nil,
      **attributes,
    )
  end
end
