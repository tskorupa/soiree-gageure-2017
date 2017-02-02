require 'rails_helper'

RSpec.describe(LotteriesHelper, type: :helper) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  describe('#lock_or_unlock') do
    it('returns "Lock registration" when lottery#locked == false') do
      assert_equal(
        'Lock registration',
        lock_or_unlock(lottery),
      )
    end

    it('returns "Unlock registration" when lottery#locked == true') do
      lottery.update!(locked: true)
      assert_equal(
        'Unlock registration',
        lock_or_unlock(lottery),
      )
    end
  end

  describe('#lock_or_unlock under I18n.locale = :fr') do
    around(:each) do |example|
      I18n.locale = :fr
      example.run
      I18n.locale = :en
    end

    it('returns "Fermer l\'enregistrement" when lottery#locked == false') do
      assert_equal(
        "Fermer l'enregistrement",
        lock_or_unlock(lottery),
      )
    end

    it('returns "Réouvrir l\'enregistrement" when lottery#locked == true') do
      lottery.update!(locked: true)
      assert_equal(
        "Réouvrir l'enregistrement",
        lock_or_unlock(lottery),
      )
    end
  end
end
