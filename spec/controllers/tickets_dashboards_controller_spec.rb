# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketsDashboardsController, type: :controller) do
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

  context('When the user is logged out') do
    describe('GET #show') do
      it('redirects to the user log in') do
        get(:show, params: { locale: I18n.locale, lottery_id: lottery.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
      get(:show, params: { locale: I18n.locale, lottery_id: lottery.id })
    end

    describe('GET #show') do
      it('assigns @tickets_dashboard') do
        expect(assigns(:tickets_dashboard)).to be_present
      end

      it('renders the "tickets_dashboards/tickets_dashboard" partial') do
        expect(response).to render_template('tickets_dashboards/_tickets_dashboard')
      end
    end
  end
end
