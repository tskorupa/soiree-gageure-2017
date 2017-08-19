# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(UsersListing, type: :model) do
  include I18nSpecHelper

  let(:users_listing) do
    UsersListing.new
  end

  describe('#title') do
    it('returns "Users" when the locale is :en') do
      with_locale(:en) do
        expect(users_listing.title).to eq('Users')
      end
    end

    it('returns "Utilisateurs" when the locale is :fr') do
      with_locale(:fr) do
        expect(users_listing.title).to eq('Utilisateurs')
      end
    end
  end

  describe('#new_user_button_name') do
    it('returns "New user" when the locale is :en') do
      with_locale(:en) do
        expect(users_listing.new_user_button_name).to eq('New user')
      end
    end

    it('returns "Nouvel utilisateur" when the locale is :fr') do
      with_locale(:fr) do
        expect(users_listing.new_user_button_name).to eq('Nouvel utilisateur')
      end
    end
  end

  describe('#user_email_colum_name') do
    it('returns "Email address" when the locale is :en') do
      with_locale(:en) do
        expect(users_listing.user_email_colum_name).to eq('Email address')
      end
    end

    it('returns "Adresse courriel" when the locale is :fr') do
      with_locale(:fr) do
        expect(users_listing.user_email_colum_name).to eq('Adresse courriel')
      end
    end
  end

  describe('#each') do
    it('assigns a row number starting at 1 to each user row') do
      2.times { |i| create_user("abc#{i}@def.com") }
      row_numbers = users_listing.map(&:row_number)
      expect(row_numbers).to eq([1, 2])
    end

    it('returns a TicketPresenter') do
      create_user
      expect(users_listing.to_a).to all(be_an_instance_of(UserRow))
    end

    it('returns an empty result set when there are no users') do
      expect(users_listing.to_a).to be_empty
    end

    it('returns user rows ordered by email address ASC') do
      expected_emails = [
        create_user('zef@def.com'),
        create_user('abc@def.com'),
        create_user('000@def.com'),
      ].map(&:email).sort

      actual_emails = users_listing.map(&:user_email)
      expect(expected_emails).to eq(actual_emails)
    end
  end

  private

  def create_user(email = 'abc@def.com')
    User.create!(
      email: email,
      password: 'foo',
    )
  end
end
