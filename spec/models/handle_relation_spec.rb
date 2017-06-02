# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(HandleRelation, type: :model) do
  let(:guest) do
    Guest.create!(full_name: 'Bubbles')
  end

  describe('#find_or_build') do
    it('returns nil when :supplied_full_name is nil') do
      expect(
        HandleRelation.find_or_build(
          klass: Guest,
          actual_entity: guest,
          supplied_full_name: nil,
        ),
      ).to be_nil
    end

    it('returns nil when :supplied_full_name is empty') do
      expect(
        HandleRelation.find_or_build(
          klass: Guest,
          actual_entity: guest,
          supplied_full_name: '',
        ),
      ).to be_nil
    end

    it('returns :actual_entity when :supplied_full_name matches actual_entity#full_name') do
      expect(
        HandleRelation.find_or_build(
          klass: Guest,
          actual_entity: guest,
          supplied_full_name: guest.full_name,
        ),
      ).to eq(guest)
    end

    it('returns an exiting entity when :supplied_full_name matches an existing entity#full_name') do
      expect(
        HandleRelation.find_or_build(
          klass: Guest,
          supplied_full_name: guest.full_name,
        ),
      ).to eq(guest)
    end

    it('returns a newly instantiated entity when :supplied_full_name does not match any existing entity#full_name') do
      entity = HandleRelation.find_or_build(
        klass: Guest,
        supplied_full_name: 'Foo',
      )
      expect(entity).to be_new_record
      expect(entity.full_name).to eq('Foo')
    end
  end
end
