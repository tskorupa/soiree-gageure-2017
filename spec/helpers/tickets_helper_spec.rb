require 'rails_helper'

RSpec.describe(TicketsHelper, type: :helper) do
  describe('#options_for_state_select') do
    it('returns english terms when locale is set to :en') do
      expect(helper.options_for_state_select).to eq(
        [
          ['Reserved', 'reserved'],
          ['Authorized', 'authorized'],
          ['Paid', 'paid'],
        ]
      )
    end

    it('returns french terms when locale is set to :fr') do
      I18n.locale = :fr
      expect(helper.options_for_state_select).to eq(
        [
          ['Réservé', 'reserved'],
          ['Authorisé', 'authorized'],
          ['Payé', 'paid'],
        ]
      )
      I18n.locale = :en
    end
  end
end
