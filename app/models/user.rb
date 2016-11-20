class User < ApplicationRecord
  devise(:database_authenticatable)
  validates(:email, :encrypted_password, presence: true)
end
