require 'rails_helper'

RSpec.describe(SellersController, type: :controller) do
  let(:seller) do
    Seller.create!(full_name: 'Gonzo')
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
        post(:create, params: { locale: I18n.locale, seller: { full_name: 'Gonzo' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('GET #show') do
      it('raises a "No route matches" error') do
        expect do
          get(:show, params: { locale: I18n.locale, id: seller.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('redirects to the user log in') do
        get(:edit, params: { locale: I18n.locale, id: seller.id })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch(:update, params: { locale: I18n.locale, id: seller.id, seller: { full_name: 'Koko' } })
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
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

    describe('GET #index') do
      it('returns all sellers ordered by LOWER(full_name)') do
        seller_1 = Seller.create!(full_name: 'z')
        seller_2 = Seller.create!(full_name: 'a')
        seller_3 = Seller.create!(full_name: '1')
        seller_4 = Seller.create!(full_name: 'A')

        get(:index, params: { locale: I18n.locale })
        expect(response).to have_http_status(:success)
        expect(assigns(:sellers)).to eq([seller_3, seller_2, seller_4, seller_1])
        expect(response).to render_template(:index)
      end
    end

    describe('GET #index with format: :json') do
      it('returns all seller full names') do
        guest_1 = Seller.create!(full_name: 'Foo')
        guest_2 = Seller.create!(full_name: 'Bar')
        guest_3 = Seller.create!(full_name: 'Baz')

        get(:index, format: :json)
        expect(response).to have_http_status(:success)
        expect(ActiveSupport::JSON.decode(response.body)).to eq(['Bar', 'Baz', 'Foo'])
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
        expect do
          get(:show, params: { locale: I18n.locale, id: seller.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end

    describe('GET #edit') do
      it('returns the requested seller') do
        get(:edit, params: { locale: I18n.locale, id: seller.id })
        expect(response).to have_http_status(:success)
        expect(assigns(:seller)).to eq(seller)
        expect(response).to render_template(:edit)
      end
    end

    describe('PATCH #update') do
      it('redirects to sellers_path when :full_name is updated') do
        patch(:update, params: { locale: I18n.locale, id: seller.id, seller: { full_name: 'Koko' } })
        expect(seller.reload.full_name).to eq('Koko')
        expect(response).to redirect_to(sellers_path)
      end

      it('renders :edit when the seller could not be updated') do
        patch(:update, params: { locale: I18n.locale, id: seller.id, seller: { full_name: nil } })
        expect(response).to have_http_status(:success)
        expect(assigns(:seller).full_name).to be_blank
        expect(seller.reload.full_name).to eq('Gonzo')
        expect(response).to render_template(:edit)
      end
    end

    describe('DELETE #destroy') do
      it('raises a "No route matches" error') do
        expect do
          delete(:destroy, params: { locale: I18n.locale, id: seller.id })
        end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
      end
    end
  end
end
