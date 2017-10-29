# frozen_string_literal: true
class SponsorRow
  include ActiveModel::Serialization

  def initialize(sponsor:, row_number:)
    @sponsor = sponsor
    @row_number = row_number
  end

  attr_reader :row_number
  delegate :to_param, to: :sponsor
  delegate :full_name, to: :sponsor, prefix: :sponsor

  def edit_sponsor_button_name
    I18n.t :'helpers.links.edit'
  end

  private

  attr_reader :sponsor
end
