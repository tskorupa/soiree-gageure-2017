# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(GuestsController, type: :controller) do
  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

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
        expect do
          get(:show, params: { locale: I18n.locale, id: guest.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, id: guest.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, id: guest.id, guest: { full_name: 'Koko' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
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

    describe('GET #index') do
      it('returns all guests ordered by LOWER(full_name)') do
        guest_1 = Guest.create!(full_name: 'z')
        guest_2 = Guest.create!(full_name: 'a')
        guest_3 = Guest.create!(full_name: '1')
        guest_4 = Guest.create!(full_name: 'A')

        get(:index, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:guests)).to eq([guest_3, guest_2, guest_4, guest_1])
        expect(response).to render_template(:index)
      end
    end

    describe('GET #index with format: :json') do
      it('returns all guest full names') do
        Guest.create!(full_name: 'Foo')
        Guest.create!(full_name: 'Bar')
        Guest.create!(full_name: 'Baz')

        get(:index, format: :json)
        expect(response).to have_http_status(:success)
        expect(ActiveSupport::JSON.decode(response.body)).to eq(%w(Bar Baz Foo))
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
        expect do
          get(:show, params: { locale: I18n.locale, id: guest.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested guest') do
        get(:edit, params: { locale: I18n.locale, id: guest.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:guest)).to eq(guest)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to guests_path when :full_name is updated') do
        patch(:update, params: { locale: I18n.locale, id: guest.id, guest: { full_name: 'Koko' } })
        expect(guest.reload.full_name).to eq('Koko')
        expect(response).to redirect_to(guests_path)
      end

      it('renders :edit when the guest could not be updated') do
        patch(:update, params: { locale: I18n.locale, id: guest.id, guest: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:guest).full_name).to be_blank
        expect(guest.reload.full_name).to eq('Bubbles')
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: guest.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
