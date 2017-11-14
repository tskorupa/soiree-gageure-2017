# frozen_string_literal: true
class SellersListing
  include Enumerable

  def title
    Seller.model_name.human.pluralize.titleize
  end

  def new_seller_button_name
    I18n.t(
      :'sellers.new.title',
      default: :'helpers.titles.new',
      model: Seller.model_name.human.downcase,
    )
  end

  def seller_full_name_column_name
    I18n.t :'column_names.seller.full_name'
  end

  def each
    sellers = Seller.order('LOWER(full_name) ASC')
    sellers.each_with_index do |seller, index|
      row_number = index + 1
      yield SellerRow.new(seller: seller, row_number: row_number)
    end
  end
end
