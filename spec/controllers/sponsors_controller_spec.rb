# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(SponsorsController, type: :controller) do
  let(:sponsor) do
    Sponsor.create!(full_name: 'Clyde')
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
        post(:create, params: { locale: I18n.locale, sponsor: { full_name: 'Clyde' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, id: sponsor.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, id: sponsor.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, id: sponsor.id, sponsor: { full_name: 'Mighty' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: sponsor.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('GET #index') do
      it('returns all sponsors ordered by LOWER(full_name)') do
        sponsor_1 = Sponsor.create!(full_name: 'z')
        sponsor_2 = Sponsor.create!(full_name: 'a')
        sponsor_3 = Sponsor.create!(full_name: '1')
        sponsor_4 = Sponsor.create!(full_name: 'A')

        get(:index, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:sponsors)).to eq([sponsor_3, sponsor_2, sponsor_4, sponsor_1])
        expect(response).to render_template(:index)
      end
    end

    describe('GET #index with format: :json') do
      it('returns all sponsor full names') do
        Sponsor.create!(full_name: 'Foo')
        Sponsor.create!(full_name: 'Bar')
        Sponsor.create!(full_name: 'Baz')

        get(:index, format: :json)
        expect(response).to have_http_status(:success)
        expect(ActiveSupport::JSON.decode(response.body)).to eq(%w(Bar Baz Foo))
      end
    end

    describe('GET #new') do
      it('returns a new sponsor') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:sponsor)).to be_a_new(Sponsor)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the sponsor_path when the sponsor was successfully created') do
        expect do
          post(:create, params: { locale: I18n.locale, sponsor: { full_name: 'Clyde' } })
        end.to change { Sponsor.count }.by(1)
        expect(response).to redirect_to(sponsors_path)
      end

      it('renders :new when the sponsor could not be persisted') do
        post(:create, params: { locale: I18n.locale, sponsor: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:sponsor)).to be_a_new(Sponsor)
        expect(response).to render_template(:new)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, id: sponsor.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested sponsor') do
        get(:edit, params: { locale: I18n.locale, id: sponsor.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:sponsor)).to eq(sponsor)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to sponsors_path when :full_name is updated') do
        patch(:update, params: { locale: I18n.locale, id: sponsor.id, sponsor: { full_name: 'Mighty' } })
        expect(sponsor.reload.full_name).to eq('Mighty')
        expect(response).to redirect_to(sponsors_path)
      end

      it('renders :edit when the sponsor could not be updated') do
        patch(:update, params: { locale: I18n.locale, id: sponsor.id, sponsor: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:sponsor).full_name).to be_blank
        expect(sponsor.reload.full_name).to eq('Clyde')
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: sponsor.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
