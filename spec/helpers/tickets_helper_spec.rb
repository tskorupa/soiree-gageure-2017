# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(TicketsHelper, type: :helper) do
  describe('#options_for_state_select') do
    it('returns english terms when locale is set to :en') do
      expect(helper.options_for_state_select).to eq(
        [
          %w(Reserved reserved),
          %w(Authorized authorized),
          %w(Paid paid),
        ],
      )
    end

    it('returns french terms when locale is set to :fr') do
      I18n.locale = :fr
      expect(helper.options_for_state_select).to eq(
        [
          %w(Réservé reserved),
          %w(Authorisé authorized),
          %w(Payé paid),
        ],
      )
      I18n.locale = :en
    end
  end
end
