require 'rails_helper'

RSpec.describe(TicketsHelper, type: :helper) do
  describe('#registration_step_label') do
    it('returns <span class="label label-default">Completed</span> when ticket#dropped_off == true') do
      ticket = double(dropped_off?: true, registered?: true)
      expect(helper.registration_step_label(ticket)).to eq('<span class="label label-default">Completed</span>')
    end

    it('returns <span class="label label-warning">Drop off</span> when ticket#dropped_off == false and ticket#registered == true') do
      ticket = double(dropped_off?: false, registered?: true)
      expect(helper.registration_step_label(ticket)).to eq('<span class="label label-warning">Drop off</span>')
    end

    it('returns <span class="label label-danger">Unregistered</span> when ticket#dropped_off == false and ticket#registered == false') do
      ticket = double(dropped_off?: false, registered?: false)
      expect(helper.registration_step_label(ticket)).to eq('<span class="label label-danger">Unregistered</span>')
    end
  end

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
