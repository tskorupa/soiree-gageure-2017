# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(GuestsHelper, type: :helper) do
  include I18nSpecHelper

  describe('#guest_column_name') do
    it('returns "Guest" when the locale is :en') do
      with_locale(:en) do
        expect(helper.guest_column_name).to eq('Guest')
      end
    end

    it('returns "Invité" when the locale is :fr') do
      with_locale(:fr) do
        expect(helper.guest_column_name).to eq('Invité')
      end
    end
  end
end
