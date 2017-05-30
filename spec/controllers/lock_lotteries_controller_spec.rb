# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(LockLotteriesController, type: :controller) do
  let(:lottery) do
    Lottery.create!(event_date: Time.zone.today)
  end

  let(:user) do
    User.create!(
      email: 'abc@def.com',
      password: 'foobar',
    )
  end

  let(:patch_update) do
    patch(:update, params: { locale: I18n.locale, id: lottery.id })
  end

  context('When the user is logged out') do
    describe('PATCH #update') do
      it('redirects to the user log in') do
        patch_update
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context('When the user is logged in') do
    before(:each) do
      sign_in(user)
    end

    describe('PATCH #update') do
      it('redirects to lotteries_path') do
        patch_update
        expect(response).to redirect_to(lotteries_path)
      end

      it('changes ticket#locked from false to true') do
        expect { patch_update }
          .to change { lottery.reload.locked }
          .from(false).to(true)
      end

      it('changes ticket#locked from true to false') do
        lottery.update!(locked: true)
        expect { patch_update }
          .to change { lottery.reload.locked }
          .from(true).to(false)
      end
    end
  end
end
