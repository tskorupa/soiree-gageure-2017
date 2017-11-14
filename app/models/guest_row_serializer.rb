# frozen_string_literal: true
class GuestRowSerializer < ActiveModel::Serializer
  attribute :guest_full_name, key: :full_name
end
