# frozen_string_literal: true
class GuestRow
  include ActiveModel::Serialization

  def initialize(guest:, row_number:)
    @guest = guest
    @row_number = row_number
  end

  attr_reader :row_number
  delegate :to_param, to: :guest
  delegate :full_name, to: :guest, prefix: :guest

  def edit_guest_button_name
    I18n.t :'helpers.links.edit'
  end

  private

  attr_reader :guest
end
