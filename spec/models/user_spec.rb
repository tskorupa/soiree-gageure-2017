# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(User, type: :model) do
  let(:user) do
    User.create!(
      email: 'abc@def.com',
      password: 'foo',
    )
  end

  describe('#valid?') do
    it('requires :email to be present') do
      new_user = User.new
      new_user.valid?
      expect(new_user.errors[:email]).to include("can't be blank")
    end

    it('requires :email to be unique') do
      new_user = User.new(email: user.email)
      new_user.valid?
      expect(new_user.errors[:email]).to include('has already been taken')
    end

    it('requires :password to be present on create') do
      new_user = User.new
      new_user.valid?
      expect(new_user.errors[:password]).to include("can't be blank")
    end

    it('requires :password to be at least 3 chars long on create') do
      new_user = User.new(password: 'a')
      new_user.valid?
      expect(new_user.errors[:password]).to include('is too short (minimum is 3 characters)')

      new_user.password = 'foo'
      new_user.valid?
      expect(new_user.errors[:password]).to be_empty
    end

    it('does not require :password to be provided on update') do
      user.valid?
      expect(user.errors[:password]).to be_empty
    end

    it('requires :password to be at least 3 chars long on update') do
      user.password = 'a'
      user.valid?
      expect(user.errors[:password]).to include('is too short (minimum is 3 characters)')

      user.password = 'foo'
      user.valid?
      expect(user.errors[:password]).to be_empty
    end
  end
end
