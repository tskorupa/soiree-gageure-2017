# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(FullNameFormatter, type: :model) do
  describe('.format') do
    it('downcases before capitalizing') do
      @full_name = 'FOO'
      expect(format).to eq('Foo')
    end

    it('keeps dashes in names') do
      @full_name = 'jean-francois proux'
      expect(format).to eq('Jean-Francois Proux')
    end

    it('strips, squeezes and capitalizes') do
      @full_name = '    foo      bar baz   '
      expect(format).to eq('Foo Bar Baz')
    end
  end

  private

  def format
    FullNameFormatter.format(@full_name)
  end
end
