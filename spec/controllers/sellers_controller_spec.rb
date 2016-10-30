require 'rails_helper'

RSpec.describe(SellersController, type: :controller) do
  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
  end

  describe('GET #index') do
    it('returns all sellers') do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:sellers)).to eq(Seller.all)
      expect(response).to render_template(:index)
    end
  end

  describe('GET #new') do
    it('returns a new seller') do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:seller)).to be_a_new(Seller)
      expect(response).to render_template(:new)
    end
  end

  describe('POST #create') do
    it('redirects to the seller_path when the seller was successfully created') do
      expect do
        post(:create, seller: { full_name: 'Gonzo' })
      end.to change { Seller.count }.by(1)
      expect(response).to redirect_to(sellers_path)
    end

    it('renders :new when the seller could not be persisted') do
      post(:create, seller: { full_name: nil })
      expect(response).to have_http_status(:success)
      expect(assigns(:seller)).to be_a_new(Seller)
      expect(response).to render_template(:new)
    end
  end

  describe('GET #show') do
    it('raises a "No route matches" error') do
      expect do
        get(:show, id: seller.id)
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end

  describe('GET #edit') do
    it('returns the requested seller') do
      get(:edit, id: seller.id)
      expect(response).to have_http_status(:success)
      expect(assigns(:seller)).to eq(seller)
      expect(response).to render_template(:edit)
    end
  end

  describe('PATCH #update') do
    it('redirects to sellers_path when :full_name is updated') do
      patch(:update, id: seller.id, seller: { full_name: 'Koko' })
      expect(seller.reload.full_name).to eq('Koko')
      expect(response).to redirect_to(sellers_path)
    end

    it('renders :edit when the seller could not be updated') do
      patch(:update, id: seller.id, seller: { full_name: nil })
      expect(response).to have_http_status(:success)
      expect(assigns(:seller).full_name).to be_blank
      expect(seller.reload.full_name).to eq('Gonzo')
      expect(response).to render_template(:edit)
    end
  end

  describe('DELETE #destroy') do
    it('raises a "No route matches" error') do
      expect do
        delete(:destroy, id: seller.id)
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end
end
