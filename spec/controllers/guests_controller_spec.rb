require 'rails_helper'

RSpec.describe(GuestsController, type: :controller) do
  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  describe('GET #index') do
    it('returns all guests') do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:guests)).to eq(Guest.all)
      expect(response).to render_template(:index)
    end
  end

  describe('GET #new') do
    it('returns a new guest') do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:guest)).to be_a_new(Guest)
      expect(response).to render_template(:new)
    end
  end

  describe('POST #create') do
    it('redirects to the guest_path when the guest was successfully created') do
      expect do
        post(:create, params: { guest: { full_name: 'Bubbles' } })
      end.to change { Guest.count }.by(1)
      expect(response).to redirect_to(guests_path)
    end

    it('renders :new when the guest could not be persisted') do
      post(:create, params: { guest: { full_name: nil } })
      expect(response).to have_http_status(:success)
      expect(assigns(:guest)).to be_a_new(Guest)
      expect(response).to render_template(:new)
    end
  end

  describe('GET #show') do
    it('raises a "No route matches" error') do
      expect do
        get(:show, params: { id: guest.id })
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end

  describe('GET #edit') do
    it('returns the requested guest') do
      get(:edit, params: { id: guest.id })
      expect(response).to have_http_status(:success)
      expect(assigns(:guest)).to eq(guest)
      expect(response).to render_template(:edit)
    end
  end

  describe('PATCH #update') do
    it('redirects to guests_path when :full_name is updated') do
      patch(:update, params: { id: guest.id, guest: { full_name: 'Koko' } })
      expect(guest.reload.full_name).to eq('Koko')
      expect(response).to redirect_to(guests_path)
    end

    it('renders :edit when the guest could not be updated') do
      patch(:update, params: { id: guest.id, guest: { full_name: nil } })
      expect(response).to have_http_status(:success)
      expect(assigns(:guest).full_name).to be_blank
      expect(guest.reload.full_name).to eq('Bubbles')
      expect(response).to render_template(:edit)
    end
  end

  describe('DELETE #destroy') do
    it('raises a "No route matches" error') do
      expect do
        delete(:destroy, params: { id: guest.id })
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end
  end
end
