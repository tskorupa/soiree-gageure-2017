# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TicketsHelper, type: :helper) do
  include I18nSpecHelper

  describe('#ticket_number_column_name') do
    it('returns "Number" when the locale is :en') do
      with_locale(:en) do
        expect(helper.ticket_number_column_name).to eq('Number')
      end
    end

    it('returns "Numéro" when the locale is :fr') do
      with_locale(:fr) do
        expect(helper.ticket_number_column_name).to eq('Numéro')
      end
    end
  end

  describe('#ticket_type_column_name') do
    it('returns "Ticket type" when the locale is :en') do
      with_locale(:en) do
        expect(helper.ticket_type_column_name).to eq('Ticket type')
      end
    end

    it('returns "Type de billet" when the locale is :fr') do
      with_locale(:fr) do
        expect(helper.ticket_type_column_name).to eq('Type de billet')
      end
    end
  end

  describe('#options_for_state_select') do
    it('returns english terms when locale is set to :en') do
      with_locale(:en) do
        expect(helper.options_for_state_select).to eq(
          [
            %w(Reserved reserved),
            %w(Authorized authorized),
            %w(Paid paid),
          ],
        )
      end
    end

    it('returns french terms when locale is set to :fr') do
      with_locale(:fr) do
        expect(helper.options_for_state_select).to eq(
          [
            %w(Réservé reserved),
            %w(Authorisé authorized),
            %w(Payé paid),
          ],
        )
      end
    end
  end
end
