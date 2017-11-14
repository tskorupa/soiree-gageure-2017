# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(GuestsController, type: :controller) do
  render_views

  let(:user) do
    User.create!(
      email: 'abc@def.com',
      password: 'foobar',
    )
  end

  context('When the user is logged out') do
    describe('GET #index') do
      it('redirects to the user log in') do
        get(:index, params: { locale: I18n.locale })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #index with format: :json') do
      it('redirects to the user log in') do
        get(:index, format: :json)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe('GET #new') do
      it('redirects to the user log in') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('POST #create') do
      it('redirects to the user log in') do
        post(:create, params: { locale: I18n.locale, guest: { full_name: 'Bubbles' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        guest = create_guest
        expect do
          get(:show, params: { locale: I18n.locale, id: guest.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        guest = create_guest
        get(:edit, params: { locale: I18n.locale, id: guest.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        guest = create_guest
        patch(:update, params: { locale: I18n.locale, id: guest.id, guest: { full_name: 'Koko' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        guest = create_guest
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: guest.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('GET #index with format: :html') do
      before(:each) do
        get(:index, params: { locale: I18n.locale })
      end

      it('assigns @guests_listing to be an instance of GuestsListing') do
        expect(assigns(:guests_listing)).to be_an_instance_of(GuestsListing)
      end

      it('renders the template "guests/index"') do
        expect(response).to render_template('guests/index')
      end

      it('renders the partial "guests/_index_header"') do
        expect(response).to render_template('guests/_index_header')
      end

      it('renders the partial "guests/_index_listing"') do
        expect(response).to render_template('guests/_index_listing')
      end

      it('returns an HTTP success') do
        expect(response).to have_http_status(:success)
      end
    end

    describe('GET #index with format: :json') do
      before(:each) do
        create_guest
        get(:index, format: :json)
      end

      it('assigns @guests_listing to be an instance of GuestsListing') do
        expect(assigns(:guests_listing)).to be_an_instance_of(GuestsListing)
      end

      it('returns a serialized list of guests') do
        expected_body = GuestsListing.new.map do |guest_row|
          GuestRowSerializer.new(guest_row).as_json
        end
        expect(response.body).to eq(expected_body.to_json)
      end

      it('returns an HTTP success') do
        expect(response).to have_http_status(:success)
      end
    end

    describe('GET #new') do
      it('returns a new guest') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:guest)).to be_a_new(Guest)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the guest_path when the guest was successfully created') do
        expect do
          post(:create, params: { locale: I18n.locale, guest: { full_name: 'Bubbles' } })
        end.to change { Guest.count }.by(1)
        expect(response).to redirect_to(guests_path)
      end

      it('renders :new when the guest could not be persisted') do
        post(:create, params: { locale: I18n.locale, guest: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:guest)).to be_a_new(Guest)
        expect(response).to render_template(:new)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        guest = create_guest
        expect do
          get(:show, params: { locale: I18n.locale, id: guest.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested guest') do
        guest = create_guest
        get(:edit, params: { locale: I18n.locale, id: guest.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:guest)).to eq(guest)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to guests_path when :full_name is updated') do
        guest = create_guest
        patch(:update, params: { locale: I18n.locale, id: guest.id, guest: { full_name: 'Koko' } })
        expect(guest.reload.full_name).to eq('Koko')
        expect(response).to redirect_to(guests_path)
      end

      it('renders :edit when the guest could not be updated') do
        guest = create_guest
        patch(:update, params: { locale: I18n.locale, id: guest.id, guest: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:guest).full_name).to be_blank
        expect(guest.reload.full_name).to eq('Bubbles')
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        guest = create_guest
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: guest.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  private

  def create_guest
    Guest.create! full_name: 'Bubbles'
  end
end
