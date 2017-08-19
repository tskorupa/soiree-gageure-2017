# frozen_string_literal: true
class UsersListing
  include Enumerable

  def title
    User.model_name.human.pluralize.titleize
  end

  def new_user_button_name
    I18n.t(
      :'users.new.title',
      default: :'helpers.titles.new',
      model: User.model_name.human.downcase,
    )
  end

  def user_email_colum_name
    I18n.t :'column_names.user.email'
  end

  def each
    users = User.order('LOWER(email) ASC')
    users.each_with_index do |user, index|
      row_number = index + 1
      yield UserRow.new(user: user, row_number: row_number)
    end
  end
end
