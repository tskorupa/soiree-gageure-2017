# frozen_string_literal: true
class UserRow
  def initialize(user:, row_number:)
    @user = user
    @row_number = row_number
  end

  attr_reader :row_number
  delegate :to_param, to: :user
  delegate :email, to: :user, prefix: :user

  def edit_user_button_name
    I18n.t :'helpers.links.edit'
  end

  private

  attr_reader :user
end
