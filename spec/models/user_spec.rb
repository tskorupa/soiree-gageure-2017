require 'rails_helper'

RSpec.describe(User, type: :model) do
  describe('#valid?') do
    before(:each) do
      @new_user = User.new
      @new_user.valid?
    end

    it('requires :email to be present') do
      expect(@new_user.errors[:email]).to include("can't be blank")
    end

    it('requires :encrypted_password to be present') do
      expect(@new_user.errors[:encrypted_password]).to include("can't be blank")
    end
  end
end
