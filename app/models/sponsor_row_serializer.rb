# frozen_string_literal: true
class SponsorRowSerializer < ActiveModel::Serializer
  attribute :sponsor_full_name, key: :full_name
end
