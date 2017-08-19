# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(UserRow, type: :model) do
  include I18nSpecHelper

  describe('#row_number') do
    it('returns the attribute it was initialized with') do
      @row_number = double
      expect(user_row.row_number).to eq(@row_number)
    end
  end

  describe('#to_param') do
    it('returns the user id') do
      @user = create_user
      expect(user_row.to_param).to eq(@user.id.to_s)
    end
  end

  describe('#user_email') do
    it('returns the user\'s email') do
      @user = create_user
      expect(user_row.to_param).to eq(@user.id.to_s)
    end
  end

  describe('#edit_user_button_name') do
    it('returns "Edit" when the locale is :en') do
      with_locale(:en) do
        expect(user_row.edit_user_button_name).to eq('Edit')
      end
    end

    it('returns "Modifier" when the locale is :fr') do
      with_locale(:fr) do
        expect(user_row.edit_user_button_name).to eq('Modifier')
      end
    end
  end

  private

  def create_user
    User.create!(
      email: 'abc@def.com',
      password: 'foo',
    )
  end

  def user_row
    UserRow.new(user: @user, row_number: @row_number)
  end
end
