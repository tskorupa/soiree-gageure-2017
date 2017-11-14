# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(SellersController, type: :controller) do
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
        post(:create, params: { locale: I18n.locale, seller: { full_name: 'Gonzo' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        seller = create_seller
        expect do
          get(:show, params: { locale: I18n.locale, id: seller.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        seller = create_seller
        get(:edit, params: { locale: I18n.locale, id: seller.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        seller = create_seller
        patch(:update, params: { locale: I18n.locale, id: seller.id, seller: { full_name: 'Koko' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        seller = create_seller
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: seller.id })
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

      it('assigns @sellers_listing to be an instance of SellersListing') do
        expect(assigns(:sellers_listing)).to be_an_instance_of(SellersListing)
      end

      it('renders the template "sellers/index"') do
        expect(response).to render_template('sellers/index')
      end

      it('renders the partial "sellers/_index_header"') do
        expect(response).to render_template('sellers/_index_header')
      end

      it('renders the partial "sellers/_index_listing"') do
        expect(response).to render_template('sellers/_index_listing')
      end

      it('returns an HTTP success') do
        expect(response).to have_http_status(:success)
      end
    end

    describe('GET #index with format: :json') do
      before(:each) do
        create_seller
        get(:index, format: :json)
      end

      it('assigns @sellers_listing to be an instance of SellersListing') do
        expect(assigns(:sellers_listing)).to be_an_instance_of(SellersListing)
      end

      it('returns a serialized list of sellers') do
        expected_body = SellersListing.new.map do |seller_row|
          SellerRowSerializer.new(seller_row).as_json
        end
        expect(response.body).to eq(expected_body.to_json)
      end

      it('returns an HTTP success') do
        expect(response).to have_http_status(:success)
      end
    end

    describe('GET #new') do
      it('returns a new seller') do
        get(:new, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:seller)).to be_a_new(Seller)
        expect(response).to render_template(:new)
      end
    end

    describe('POST #create') do
      it('redirects to the seller_path when the seller was successfully created') do
        expect do
          post(:create, params: { locale: I18n.locale, seller: { full_name: 'Gonzo' } })
        end.to change { Seller.count }.by(1)
        expect(response).to redirect_to(sellers_path)
      end

      it('renders :new when the seller could not be persisted') do
        post(:create, params: { locale: I18n.locale, seller: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:seller)).to be_a_new(Seller)
        expect(response).to render_template(:new)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        seller = create_seller
        expect do
          get(:show, params: { locale: I18n.locale, id: seller.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested seller') do
        seller = create_seller
        get(:edit, params: { locale: I18n.locale, id: seller.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:seller)).to eq(seller)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to sellers_path when :full_name is updated') do
        seller = create_seller
        patch(:update, params: { locale: I18n.locale, id: seller.id, seller: { full_name: 'Koko' } })
        expect(seller.reload.full_name).to eq('Koko')
        expect(response).to redirect_to(sellers_path)
      end

      it('renders :edit when the seller could not be updated') do
        seller = create_seller
        patch(:update, params: { locale: I18n.locale, id: seller.id, seller: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:seller).full_name).to be_blank
        expect(seller.reload.full_name).to eq('Gonzo')
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        seller = create_seller
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: seller.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end

  private

  def create_seller
    Seller.create! full_name: 'Gonzo'
  end
end
