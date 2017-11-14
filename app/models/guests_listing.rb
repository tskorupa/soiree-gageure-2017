# frozen_string_literal: true
class GuestsListing
  include Enumerable

  def title
    Guest.model_name.human.pluralize.titleize
  end

  def new_guest_button_name
    I18n.t(
      :'guests.new.title',
      default: :'helpers.titles.new',
      model: Guest.model_name.human.downcase,
    )
  end

  def guest_full_name_column_name
    I18n.t :'column_names.guest.full_name'
  end

  def each
    guests = Guest.order('LOWER(full_name) ASC')
    guests.each_with_index do |guest, index|
      row_number = index + 1
      yield GuestRow.new(guest: guest, row_number: row_number)
    end
  end
end
