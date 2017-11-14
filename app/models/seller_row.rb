# frozen_string_literal: true
class SellerRow
  include ActiveModel::Serialization

  def initialize(seller:, row_number:)
    @seller = seller
    @row_number = row_number
  end

  attr_reader :row_number
  delegate :to_param, to: :seller
  delegate :full_name, to: :seller, prefix: :seller

  def edit_seller_button_name
    I18n.t :'helpers.links.edit'
  end

  private

  attr_reader :seller
end
