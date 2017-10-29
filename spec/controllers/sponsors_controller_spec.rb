# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SponsorsController, type: :controller) do
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
        post(:create, params: { locale: I18n.locale, sponsor: { full_name: 'Clyde' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        sponsor = create_sponsor
        expect do
          get(:show, params: { locale: I18n.locale, id: sponsor.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        sponsor = create_sponsor
        get(:edit, params: { locale: I18n.locale, id: sponsor.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        sponsor = create_sponsor
        patch(:update, params: { locale: I18n.locale, id: sponsor.id, sponsor: { full_name: 'Mighty' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        sponsor = create_sponsor
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

    describe('GET #index with format: :html') do
      before(:each) do
        get(:index, params: { locale: I18n.locale })
      end

      it('assigns @sponsors_listing to be an instance of SponsorListing') do
        expect(assigns(:sponsors_listing)).to be_an_instance_of(SponsorListing)
      end

      it('renders the template "sponsors/index"') do
        expect(response).to render_template('sponsors/index')
      end

      it('renders the partial "sponsors/_index_header"') do
        expect(response).to render_template('sponsors/_index_header')
      end

      it('renders the partial "sponsors/_index_listing"') do
        expect(response).to render_template('sponsors/_index_listing')
      end

      it('returns an HTTP success') do
        expect(response).to have_http_status(:success)
      end
    end

    describe('GET #index with format: :json') do
      before(:each) do
        create_sponsor
        get(:index, format: :json)
      end

      it('assigns @sponsors_listing to be an instance of SponsorListing') do
        expect(assigns(:sponsors_listing)).to be_an_instance_of(SponsorListing)
      end

      it('returns a serialized list of sponsors') do
        expected_body = SponsorListing.new.map do |sponsor_row|
          SponsorRowSerializer.new(sponsor_row).as_json
        end
        expect(response.body).to eq(expected_body.to_json)
      end

      it('returns an HTTP success') do
        expect(response).to have_http_status(:success)
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
        sponsor = create_sponsor
        expect do
          get(:show, params: { locale: I18n.locale, id: sponsor.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested sponsor') do
        sponsor = create_sponsor
        get(:edit, params: { locale: I18n.locale, id: sponsor.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:sponsor)).to eq(sponsor)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to sponsors_path when :full_name is updated') do
        sponsor = create_sponsor
        patch(:update, params: { locale: I18n.locale, id: sponsor.id, sponsor: { full_name: 'Mighty' } })
        expect(sponsor.reload.full_name).to eq('Mighty')
        expect(response).to redirect_to(sponsors_path)
      end

      it('renders :edit when the sponsor could not be updated') do
        sponsor = create_sponsor
        patch(:update, params: { locale: I18n.locale, id: sponsor.id, sponsor: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:sponsor).full_name).to be_blank
        expect(sponsor.reload.full_name).to eq('Clyde')
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        sponsor = create_sponsor
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: sponsor.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  private

  def create_sponsor
    Sponsor.create! full_name: 'Clyde'
  end
end
