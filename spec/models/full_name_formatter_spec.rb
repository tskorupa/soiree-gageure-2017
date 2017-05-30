# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(FullNameFormatter, type: :model) do
  describe('.format') do
    it('strips, squeezes and titleizes') do
      input_string = '    foo      bar baz   '
      expect(FullNameFormatter.format(input_string)).to eq('Foo Bar Baz')
    end
  end
end
