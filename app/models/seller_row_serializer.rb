# frozen_string_literal: true
class SellerRowSerializer < ActiveModel::Serializer
  attribute :seller_full_name, key: :full_name
end
