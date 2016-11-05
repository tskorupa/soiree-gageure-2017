require 'rails_helper'

RSpec.describe(Table, type: :model) do
  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  let(:table) do
    Table.create!(
      lottery: lottery,
      number: 1,
      capacity: 6,
    )
  end

  describe('#number') do
    it('is indexed') do
      expect(
        ActiveRecord::Base.connection.index_exists?(:tables, :number),
      ).to be(true)
    end

    it('is unique per lottery') do
      expect(
        ActiveRecord::Base.connection.index_exists?(
          :tables,
          [:lottery_id, :number],
          unique: true,
        ),
      ).to be(true)
    end
  end

  describe('#valid?') do
    it ('requires a lottery') do
      new_table = Table.new
      expect(new_table).not_to be_valid
      expect(new_table.errors[:lottery]).to include("must exist")
    end

    it('requires :number to be a number') do
      new_table = Table.new
      expect(new_table).not_to be_valid
      expect(new_table.errors[:number]).to include('is not a number')
    end

    it('requires :number to be an integer') do
      new_table = Table.new(number: 3.3)
      expect(new_table).not_to be_valid
      expect(new_table.errors[:number]).to include('must be an integer')
    end

    it('requires :number to be greater than 0') do
      new_table = Table.new(number: 0)
      expect(new_table).not_to be_valid
      expect(new_table.errors[:number]).to include('must be greater than 0')
    end

    it('requires :number to be unique per lottery') do
      new_table = Table.new(
        lottery: lottery,
        number: table.number,
        capacity: 5,
      )
      expect(new_table).not_to be_valid
      expect(new_table.errors[:number]).to include('has already been taken')
    end

    it('requires :capacity to be a capacity') do
      new_table = Table.new
      expect(new_table).not_to be_valid
      expect(new_table.errors[:capacity]).to include('is not a number')
    end

    it('requires :capacity to be an integer') do
      new_table = Table.new(capacity: 3.3)
      expect(new_table).not_to be_valid
      expect(new_table.errors[:capacity]).to include('must be an integer')
    end

    it('requires :capacity to be greater than 0') do
      new_table = Table.new(capacity: 0)
      expect(new_table).not_to be_valid
      expect(new_table.errors[:capacity]).to include('must be greater than 0')
    end
  end

  describe('#lottery') do
    it('returns the parent lottery') do
      expect(table.lottery).to eq(lottery)
    end
  end
end
