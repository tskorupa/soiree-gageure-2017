# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(UsersController, type: :controller) do
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

    describe('GET #new') do
      it('redirects to the user log in') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('POST #create') do
      it('redirects to the user log in') do
        post(:create, params: { locale: I18n.locale, user: { email: 'abc@def.com', password: 'foobar' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, id: user.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, id: user.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, id: user.id, user: { email: 'abc@def.com', password: 'foobar' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: user.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('GET #index') do
      before(:each) do
        get(:index, params: { locale: I18n.locale })
      end

      it('assigns @users') do
        expect(assigns(:users)).to eq([user])
      end

      it('renders the template "users/index"') do
        expect(response).to render_template('users/index')
      end

      it('renders the partial "users/_index_header"') do
        expect(response).to render_template('users/_index_header')
      end

      it('renders the partial "users/_index_listing"') do
        expect(response).to render_template('users/_index_listing')
      end

      it('returns an HTTP success') do
        expect(response).to have_http_status(:success)
      end
    end

    describe('GET #new') do
      it('returns a new user') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to be_a_new(User)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the user_path when the user was successfully created') do
        expect do
          post(:create, params: { locale: I18n.locale, user: { email: 'zzz@zzz.com', password: 'foobar' } })
        end.to change { User.count }.by(1)
        expect(response).to redirect_to(users_path)
      end

      it('renders :new when the user could not be persisted') do
        post(:create, params: { locale: I18n.locale, user: { email: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to be_a_new(User)
        expect(response).to render_template(:new)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, id: user.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested user') do
        get(:edit, params: { locale: I18n.locale, id: user.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to users_path when :email is updated') do
        patch(:update, params: { locale: I18n.locale, id: user.id, user: { email: 'zzz@zzz.com' } })
        expect(user.reload.email).to eq('zzz@zzz.com')
        expect(response).to redirect_to(users_path)
      end

      it('redirects to users_path when :password is updated') do
        patch(:update, params: { locale: I18n.locale, id: user.id, user: { password: 'bar' } })
        expect(user.reload.valid_password?('bar')).to be(true)
        expect(response).to redirect_to(users_path)
      end

      it('renders :edit when the user could not be updated') do
        patch(:update, params: { locale: I18n.locale, id: user.id, user: { email: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:user).email).to be_blank
        expect(user.reload.email).to eq('abc@def.com')
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: user.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
