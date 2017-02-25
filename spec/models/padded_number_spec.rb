require 'rails_helper'

RSpec.describe(PaddedNumber, type: :model) do
  describe('.pad_number') do
    let(:pad_number) do
      PaddedNumber.pad_number(@number)
    end

    it('returns "003" when the number is 3') do
      @number = 3
      expect(pad_number).to eq('003')
    end

    it('returns "013" when the number is 13') do
      @number = 13
      expect(pad_number).to eq('013')
    end

    it('returns "324" when the number is 324') do
      @number = 324
      expect(pad_number).to eq('324')
    end
  end
end
