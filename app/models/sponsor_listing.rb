# frozen_string_literal: true
class SponsorListing
  include Enumerable

  def title
    Sponsor.model_name.human.pluralize.titleize
  end

  def new_sponsor_button_name
    I18n.t(
      :'sponsors.new.title',
      default: :'helpers.titles.new',
      model: Sponsor.model_name.human.downcase,
    )
  end

  def sponsor_full_name_column_name
    I18n.t :'column_names.sponsor.full_name'
  end

  def each
    sponsors = Sponsor.order('LOWER(full_name) ASC')
    sponsors.each_with_index do |sponsor, index|
      row_number = index + 1
      yield SponsorRow.new(sponsor: sponsor, row_number: row_number)
    end
  end
end
