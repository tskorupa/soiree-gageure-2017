# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(TablesHelper, type: :helper) do
  include I18nSpecHelper

  describe('#table_column_name') do
    it('returns "Table" when the locale is :en') do
      with_locale(:en) do
        expect(helper.table_column_name).to eq('Table')
      end
    end

    it('returns "Table" when the locale is :fr') do
      with_locale(:fr) do
        expect(helper.table_column_name).to eq('Table')
      end
    end
  end
end
