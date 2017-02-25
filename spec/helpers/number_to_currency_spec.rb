require 'rails_helper'

RSpec.describe('number_to_currency', type: :helper) do
  include I18nHelper

  it('returns $123,456,789.00 when locale is :en') do
    expect(number_to_currency(123_456_789)).to eq('$123,456,789.00')
  end

  it('returns 123 456 789,00$ when locale is :fr') do
    with_locale(:fr) do
      expect(number_to_currency(123_456_789)).to eq('123 456 789,00 $')
    end
  end
end
